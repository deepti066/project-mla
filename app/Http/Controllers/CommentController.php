<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use App\Models\Post;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    /**
     * Get all comments for a post
     */
    public function index(Post $post, Request $request)
    {
        $request->validate([
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:50',
        ]);

        $perPage = $request->query('per_page', 20);

        $comments = $post->comments()
            ->whereNull('parent_comment_id') // Only top-level comments
            ->with(['user', 'replies.user'])
            ->latest()
            ->paginate($perPage);

        return response()->json([
            'data' => $comments->map(fn($comment) => $this->formatComment($comment)),
            'pagination' => [
                'total' => $comments->total(),
                'current_page' => $comments->currentPage(),
                'per_page' => $comments->perPage(),
                'last_page' => $comments->lastPage(),
            ],
        ]);
    }

    /**
     * Create a new comment
     */
    public function store(Request $request, Post $post)
    {
        $request->validate([
            'body' => 'required|string|max:1000',
            'parent_comment_id' => 'nullable|exists:comments,id',
        ]);

        $comment = Comment::create([
            'user_id' => $request->user()->id,
            'post_id' => $post->id,
            'parent_comment_id' => $request->parent_comment_id,
            'body' => $request->body,
        ]);

        $comment->load(['user', 'replies.user']);

        // TODO: Send notification to post author or comment owner

        return response()->json([
            'message' => 'Comment created successfully',
            'comment' => $this->formatComment($comment),
        ], 201);
    }

    /**
     * Update a comment
     */
    public function update(Request $request, Comment $comment)
    {
        if ($comment->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'body' => 'required|string|max:1000',
        ]);

        $comment->update(['body' => $request->body]);

        return response()->json([
            'message' => 'Comment updated successfully',
            'comment' => $this->formatComment($comment),
        ]);
    }

    /**
     * Delete a comment
     */
    public function destroy(Request $request, Comment $comment)
    {
        if ($comment->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $comment->delete();

        return response()->json(['message' => 'Comment deleted successfully']);
    }

    /**
     * Helper method to format comment response
     */
    private function formatComment(Comment $comment)
    {
        return [
            'id' => $comment->id,
            'user' => [
                'id' => $comment->user->id,
                'name' => $comment->user->name,
                'avatar' => $comment->user->avatar_url,
                'is_verified' => $comment->user->is_verified,
            ],
            'body' => $comment->body,
            'replies' => $comment->replies->map(fn($reply) => $this->formatComment($reply)),
            'created_at' => $comment->created_at,
            'updated_at' => $comment->updated_at,
        ];
    }
}
