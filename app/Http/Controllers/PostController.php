<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'content' => 'required|string',
            'media' => 'nullable|file|mimes:jpg,png,mp4|max:10240', // 10MB max
        ]);

        if (!$request->user()->isAdmin()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $post = new Post();
        $post->user_id = $request->user()->id;
        $post->content = $request->content;

        if ($request->hasFile('media')) {
            $file = $request->file('media');
            $path = $file->store('media', 'public');
            $post->media_url = Storage::url($path);
            $post->media_type = $file->getClientMimeType() == 'video/mp4' ? 'video' : 'image';
        }

        $post->save();

        return response()->json(['message' => 'Post created', 'post' => $post], 201);
    }

    public function index()
    {
        $posts = Post::with('user')->latest()->get();
        return response()->json($posts);
    }
}
