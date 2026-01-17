<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Share;
use Illuminate\Http\Request;

class ShareController extends Controller
{
    /**
     * Share a post
     */
    public function store(Request $request, Post $post)
    {
        $request->validate([
            'shared_to' => 'nullable|string|max:50', // 'story', 'direct_message', etc.
        ]);

        $userId = $request->user()->id;

        // Check if already shared in the same way
        $existingShare = Share::where('user_id', $userId)
            ->where('post_id', $post->id)
            ->where('shared_to', $request->shared_to)
            ->first();

        if ($existingShare) {
            return response()->json(['message' => 'You have already shared this post'], 400);
        }

        Share::create([
            'user_id' => $userId,
            'post_id' => $post->id,
            'shared_to' => $request->shared_to,
        ]);

        // TODO: Send notification to post author

        return response()->json([
            'message' => 'Post shared successfully',
            'shares_count' => $post->shares()->count(),
        ]);
    }

    /**
     * Get all shares for a post
     */
    public function index(Post $post, Request $request)
    {
        $request->validate([
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:50',
        ]);

        $perPage = $request->query('per_page', 50);

        $shares = $post->shares()
            ->with('user')
            ->latest()
            ->paginate($perPage);

        return response()->json([
            'data' => $shares->map(fn($share) => [
                'id' => $share->id,
                'user' => [
                    'id' => $share->user->id,
                    'name' => $share->user->name,
                    'avatar' => $share->user->avatar_url,
                ],
                'shared_to' => $share->shared_to,
                'created_at' => $share->created_at,
            ]),
            'pagination' => [
                'total' => $shares->total(),
                'current_page' => $shares->currentPage(),
            ],
        ]);
    }

    /**
     * Remove a share
     */
    public function destroy(Request $request, Share $share)
    {
        if ($share->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $share->delete();

        return response()->json(['message' => 'Share removed successfully']);
    }
}
