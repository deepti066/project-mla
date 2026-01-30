<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Follow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Get authenticated user profile
     */
    public function me(Request $request)
    {
        $user = $request->user()->load(['posts', 'followers', 'following']);

        return response()->json($this->formatUserProfile($user));
    }

    /**
     * Get user profile by ID
     */
    public function show(Request $request, User $user)
    {
        if ($user->trashed()) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $user->load(['posts' => function ($query) {
            $query->published()->notArchived();
        }, 'followers', 'following']);

        $profile = $this->formatUserProfile($user);

        // Add relationship status for authenticated user
        if ($request->user()) {
            $profile['is_following'] = $request->user()->isFollowing($user);
            $profile['is_followed_by'] = $request->user()->isFollowedBy($user);
        }

        return response()->json($profile);
    }

    /**
     * Update user profile
     */
    public function update(Request $request)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'bio' => 'sometimes|string|max:500',
            'avatar' => 'sometimes|image|mimes:jpg,jpeg,png,gif|max:5120', // 5MB
            'is_private' => 'sometimes|boolean',
        ]);

        $user = $request->user();

        // Handle avatar upload
        if ($request->hasFile('avatar')) {
            // Delete old avatar if exists
            if ($user->avatar_url) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $user->avatar_url));
            }

            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar_url = Storage::url($path);
        }

        // Update other fields
        $user->update($request->only(['name', 'bio', 'is_private']));

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $this->formatUserProfile($user),
        ]);
    }

    /**
     * Change password
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json(['message' => 'Current password is incorrect'], 400);
        }

        $user->update(['password' => Hash::make($request->new_password)]);

        return response()->json(['message' => 'Password changed successfully']);
    }

    /**
     * Follow a user
     */
    public function follow(Request $request, User $user)
    {
        $authUser = $request->user();

        if ($authUser->id === $user->id) {
            return response()->json(['message' => 'You cannot follow yourself'], 400);
        }

        // Check if already following
        if ($authUser->isFollowing($user)) {
            return response()->json(['message' => 'You are already following this user'], 400);
        }

        Follow::create([
            'follower_id' => $authUser->id,
            'following_id' => $user->id,
        ]);

        // TODO: Send notification to user being followed

        return response()->json([
            'message' => 'User followed successfully',
            'followers_count' => $user->followers()->count(),
        ]);
    }

    /**
     * Unfollow a user
     */
    public function unfollow(Request $request, User $user)
    {
        $authUser = $request->user();

        Follow::where('follower_id', $authUser->id)
            ->where('following_id', $user->id)
            ->delete();

        return response()->json([
            'message' => 'User unfollowed successfully',
            'followers_count' => $user->followers()->count(),
        ]);
    }

    /**
     * Get user's followers
     */
    public function followers(User $user, Request $request)
    {
        $request->validate([
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:50',
        ]);

        $perPage = $request->query('per_page', 20);

        $followers = $user->followers()
            ->with('follower')
            ->paginate($perPage);

        return response()->json([
            'data' => $followers->map(fn($follow) => $this->formatUserCard($follow->follower)),
            'pagination' => [
                'total' => $followers->total(),
                'current_page' => $followers->currentPage(),
                'per_page' => $followers->perPage(),
            ],
        ]);
    }

    /**
     * Get user's following
     */
    public function following(User $user, Request $request)
    {
        $request->validate([
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:50',
        ]);

        $perPage = $request->query('per_page', 20);

        $following = $user->following()
            ->with('following')
            ->paginate($perPage);

        return response()->json([
            'data' => $following->map(fn($follow) => $this->formatUserCard($follow->following)),
            'pagination' => [
                'total' => $following->total(),
                'current_page' => $following->currentPage(),
                'per_page' => $following->perPage(),
            ],
        ]);
    }

    /**
     * Search users
     */
    public function search(Request $request)
    {
        $request->validate([
            'q' => 'required|string|min:1|max:100',
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:50',
        ]);

        $query = $request->query('q');
        $perPage = $request->query('per_page', 15);

        $users = User::where('name', 'like', "%$query%")
            ->orWhere('email', 'like', "%$query%")
            ->where('deleted_at', null)
            ->paginate($perPage);

        return response()->json([
            'data' => $users->map(fn($user) => $this->formatUserCard($user)),
            'pagination' => [
                'total' => $users->total(),
                'current_page' => $users->currentPage(),
                'per_page' => $users->perPage(),
            ],
        ]);
    }

    /**
     * Helper method to format user profile response
     */
    private function formatUserProfile(User $user)
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'avatar' => $user->avatar_url,
            'bio' => $user->bio,
            'role' => $user->role,
            'is_admin' => $user->isAdmin(),
            'is_verified' => $user->is_verified,
            'is_private' => $user->is_private,
            'stats' => [
                'posts_count' => $user->posts()->notArchived()->count(),
                'followers_count' => $user->followers()->count(),
                'following_count' => $user->following()->count(),
            ],
            'last_seen_at' => $user->last_seen_at,
        ];
    }

    /**
     * Helper method to format user card (compact user info)
     */
    private function formatUserCard(User $user)
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'avatar' => $user->avatar_url,
            'is_verified' => $user->is_verified,
            'bio' => $user->bio,
            'is_admin' => $user->isAdmin(),
        ];
    }
}
