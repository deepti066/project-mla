<?php

use App\Http\Controllers\AnalyticsController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PostController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::post('/posts', [PostController::class, 'store']);
    Route::get('/posts', [PostController::class, 'index']);
    Route::get('/analytics', [AnalyticsController::class, 'index']);
    Route::post('/views', [AnalyticsController::class, 'storeView']);
    Route::post('/notifications', [NotificationController::class, 'sendNotification']);
    Route::post('/update-fcm-token', [AuthController::class, 'updateFcmToken']);
});
