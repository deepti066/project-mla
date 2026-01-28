<?php

use App\Http\Controllers\AnalyticsController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\ShareController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/**
 * Authentication Routes (Public)
 */
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

/**
 * Authenticated Routes
 */
Route::middleware('auth:sanctum')->group(function () {

    // User Profile Routes
    Route::get('/user/me', [UserController::class, 'me']);
    Route::put('/user/profile', [UserController::class, 'update']);
    Route::post('/user/change-password', [UserController::class, 'changePassword']);
    Route::get('/user/{user}', [UserController::class, 'show']);
    Route::post('/user/{user}/follow', [UserController::class, 'follow']);
    Route::post('/user/{user}/unfollow', [UserController::class, 'unfollow']);
    Route::get('/user/{user}/followers', [UserController::class, 'followers']);
    Route::get('/user/{user}/following', [UserController::class, 'following']);
    Route::get('/user/search', [UserController::class, 'search']);

    // Post Routes
    Route::post('/posts', [PostController::class, 'store']); // Create post (Admin only)
    Route::get('/posts', [PostController::class, 'index']); // Get all posts (public feed)
    Route::get('/posts/feed', [PostController::class, 'feed']); // Get personalized feed
    Route::get('/posts/{post}', [PostController::class, 'show']); // Get single post
    Route::put('/posts/{post}', [PostController::class, 'update']); // Update post (Admin only)
    Route::delete('/posts/{post}', [PostController::class, 'destroy']); // Delete post (Admin only)

    // Post Like Routes
    Route::post('/posts/{post}/like', [PostController::class, 'like']);
    Route::post('/posts/{post}/unlike', [PostController::class, 'unlike']);
    Route::get('/posts/{post}/likes', [PostController::class, 'getLikes']);

    // Post Comment Routes
    Route::get('/posts/{post}/comments', [CommentController::class, 'index']);
    Route::post('/posts/{post}/comments', [CommentController::class, 'store']);
    Route::put('/comments/{comment}', [CommentController::class, 'update']);
    Route::delete('/comments/{comment}', [CommentController::class, 'destroy']);

    // Post Share Routes
    Route::post('/posts/{post}/share', [ShareController::class, 'store']);
    Route::get('/posts/{post}/shares', [ShareController::class, 'index']);
    Route::delete('/shares/{share}', [ShareController::class, 'destroy']);

    // Analytics & Notifications
    Route::get('/analytics', [AnalyticsController::class, 'index']);
    Route::post('/views', [AnalyticsController::class, 'storeView']);
    Route::post('/notifications', [NotificationController::class, 'sendNotification']);
    Route::post('/update-fcm-token', [AuthController::class, 'updateFcmToken']);

    // Fallback auth check
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});

