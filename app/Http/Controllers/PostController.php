<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Like;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    /**
     * Create a new post (Admin only)
     */
    public function store(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['message' => 'Unauthorized. Only admins can create posts.'], 403);
        }

        $request->validate([
            'caption' => 'required|string|max:2500',
            'media' => 'nullable|array|min:1|max:10',
            'media.*' => 'file|mimes:jpg,jpeg,png,gif,mp4,mov|max:102400', // 100MB max per file
        ]);

        $post = Post::create([
            'user_id' => $request->user()->id,
            'caption' => $request->caption,
            'published_at' => now(),
        ]);

        // Handle multiple media files
        if ($request->hasFile('media')) {
            $mediaFiles = $request->file('media');
            foreach ($mediaFiles as $index => $file) {
                $path = $file->store('posts', 'public');
                $mimeType = $file->getMimeType();
                
                $mediaType = str_starts_with($mimeType, 'video/') ? 'video' : 'image';
                $thumbnailUrl = null;

                // TODO: Generate video thumbnail using FFmpeg
                if ($mediaType === 'video') {
                    $thumbnailUrl = null; // You'll implement video thumbnail generation later
                }

                $post->media()->create([
                    'media_type' => $mediaType,
                    'media_url' => Storage::url($path),
                    'thumbnail_url' => $thumbnailUrl,
                    'order' => $index,
                ]);
            }
        }

        return response()->json([
            'message' => 'Post created successfully',
            'post' => $this->formatPost($post),
        ], 201);
    }

    /**
     * Get paginated posts feed
     */
    public function index(Request $request)
    {
        $request->validate([
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:50',
        ]);

        $perPage = $request->query('per_page', 15);
        
        $posts = Post::with(['user', 'media', 'likes', 'comments'])
            ->published()
            ->notArchived()
            ->latest('published_at')
            ->paginate($perPage);

        return response()->json([
            'data' => $posts->map(fn($post) => $this->formatPost($post)),
            'pagination' => [
                'total' => $posts->total(),
                'current_page' => $posts->currentPage(),
                'per_page' => $posts->perPage(),
                'last_page' => $posts->lastPage(),
                'has_more' => $posts->hasMorePages(),
            ],
        ]);
    }

    /**
     * Get personalized feed for authenticated user
     */
    public function feed(Request $request)
    {
        $request->validate([
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:50',
        ]);

        $user = $request->user();
        $perPage = $request->query('per_page', 15);

        // Get posts from users that the authenticated user follows, plus their own posts
        $followingIds = $user->following()->pluck('following_id')->toArray();
        $followingIds[] = $user->id; // Include own posts

        $posts = Post::with(['user', 'media', 'likes', 'comments'])
            ->whereIn('user_id', $followingIds)
            ->published()
            ->notArchived()
            ->latest('published_at')
            ->paginate($perPage);

        return response()->json([
            'data' => $posts->map(fn($post) => $this->formatPost($post, $user)),
            'pagination' => [
                'total' => $posts->total(),
                'current_page' => $posts->currentPage(),
                'per_page' => $posts->perPage(),
                'last_page' => $posts->lastPage(),
                'has_more' => $posts->hasMorePages(),
            ],
        ]);
    }

    /**
     * Get a single post by ID
     */
    public function show(Request $request, Post $post)
    {
        if ($post->trashed()) {
            return response()->json(['message' => 'Post not found'], 404);
        }

        $post->load(['user', 'media', 'likes', 'comments.user']);

        // Record view
        if ($request->user()) {
            $post->views()->firstOrCreate([
                'user_id' => $request->user()->id,
            ]);
        }

        return response()->json($this->formatPost($post, $request->user()));
    }

    /**
     * Update a post (Admin only, own posts)
     */
    public function update(Request $request, Post $post)
    {
        if ($post->user_id !== $request->user()->id || !$request->user()->isAdmin()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'caption' => 'sometimes|string|max:2500',
            'is_archived' => 'sometimes|boolean',
        ]);

        $post->update($request->only(['caption', 'is_archived']));

        return response()->json([
            'message' => 'Post updated successfully',
            'post' => $this->formatPost($post),
        ]);
    }

    /**
     * Delete a post (Admin only, own posts)
     */
    public function destroy(Request $request, Post $post)
    {
        if ($post->user_id !== $request->user()->id || !$request->user()->isAdmin()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Delete associated media files
        foreach ($post->media as $media) {
            Storage::disk('public')->delete(str_replace('/storage/', '', $media->media_url));
        }

        $post->delete();

        return response()->json(['message' => 'Post deleted successfully']);
    }

    /**
     * Like a post
     */
    public function like(Request $request, Post $post)
    {
        $userId = $request->user()->id;

        // Check if already liked
        if ($post->likes()->where('user_id', $userId)->exists()) {
            return response()->json(['message' => 'You have already liked this post'], 400);
        }

        Like::create([
            'user_id' => $userId,
            'post_id' => $post->id,
        ]);

        // TODO: Send notification to post author

        return response()->json([
            'message' => 'Post liked successfully',
            'likes_count' => $post->likes()->count(),
        ]);
    }

    /**
     * Unlike a post
     */
    public function unlike(Request $request, Post $post)
    {
        $post->likes()->where('user_id', $request->user()->id)->delete();

        return response()->json([
            'message' => 'Like removed successfully',
            'likes_count' => $post->likes()->count(),
        ]);
    }

    /**
     * Get all likes for a post
     */
    public function getLikes(Post $post)
    {
        $likes = $post->likes()
            ->with('user')
            ->latest()
            ->paginate(50);

        return response()->json([
            'data' => $likes->map(fn($like) => [
                'id' => $like->user->id,
                'name' => $like->user->name,
                'avatar' => $like->user->avatar_url,
                'username' => $like->user->email, // Using email as username
            ]),
            'pagination' => [
                'total' => $likes->total(),
                'current_page' => $likes->currentPage(),
            ],
        ]);
    }

    /**
     * Helper method to format post response
     */
    private function formatPost(Post $post, $authUser = null)
    {
        $post->load(['user', 'media', 'likes', 'comments.user']);

        return [
            'id' => $post->id,
            'user' => [
                'id' => $post->user->id,
                'name' => $post->user->name,
                'avatar' => $post->user->avatar_url,
                'is_verified' => $post->user->is_verified,
            ],
            'caption' => $post->caption,
            'media' => $post->media->map(fn($m) => [
                'id' => $m->id,
                'type' => $m->media_type,
                'url' => $m->media_url,
                'thumbnail' => $m->thumbnail_url,
            ]),
            'engagement' => [
                'likes_count' => $post->likes->count(),
                'comments_count' => $post->comments->count(),
                'shares_count' => $post->shares()->count(),
                'views_count' => $post->views()->count(),
            ],
            'is_liked' => $authUser ? $post->likes()->where('user_id', $authUser->id)->exists() : false,
            'created_at' => $post->created_at,
            'updated_at' => $post->updated_at,
        ];
    }
}
