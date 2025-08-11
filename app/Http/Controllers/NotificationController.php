<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;

class NotificationController extends Controller
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(config('services.firebase.credentials'));
        $this->messaging = $factory->createMessaging();
    }

    public function sendNotification(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'post_id' => 'required|exists:posts,id',
            'title' => 'required|string',
            'body' => 'required|string',
        ]);

        $users = User::where('role', 'follower')->get();
        $tokens = $users->pluck('fcm_token')->filter()->toArray();

        if (empty($tokens)) {
            return response()->json(['message' => 'No devices registered'], 400);
        }

        $message = CloudMessage::new()
            ->withNotification([
                'title' => $request->title,
                'body' => $request->body,
            ])
            ->withData(['post_id' => $request->post_id]);

        $this->messaging->sendMulticast($message, $tokens);

        return response()->json(['message' => 'Notification sent']);
    }
}
