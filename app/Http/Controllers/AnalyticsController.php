<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\View;
use Illuminate\Http\Request;

class AnalyticsController extends Controller
{
    public function index(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $analytics = Post::withCount('views')->get();

        return response()->json($analytics);
    }

    public function storeView(Request $request)
    {
        $request->validate([
            'post_id' => 'required|exists:posts,id',
        ]);

        View::create([
            'user_id' => $request->user()->id,
            'post_id' => $request->post_id,
        ]);

        return response()->json(['message' => 'View recorded']);
    }
}
