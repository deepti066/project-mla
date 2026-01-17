<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name', 'email', 'password', 'role', 'bio', 'avatar_url', 
        'is_verified', 'fcm_token', 'last_seen_at', 'is_private',
    ];

    protected $hidden = [
        'password', 'remember_token', 'fcm_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'last_seen_at' => 'datetime',
        'is_verified' => 'boolean',
        'is_private' => 'boolean',
    ];

    // Relationships

    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public function comments()
    {
        return $this->hasMany(Comment::class);
    }

    public function likes()
    {
        return $this->hasMany(Like::class);
    }

    public function views()
    {
        return $this->hasMany(View::class);
    }

    public function shares()
    {
        return $this->hasMany(Share::class);
    }

    // Follow relationships
    public function followers()
    {
        return $this->hasMany(Follow::class, 'following_id');
    }

    public function following()
    {
        return $this->hasMany(Follow::class, 'follower_id');
    }

    // Helper methods
    
    public function followersCount()
    {
        return $this->followers()->count();
    }

    public function followingCount()
    {
        return $this->following()->count();
    }

    public function isFollowing(User $user)
    {
        return $this->following()
            ->where('following_id', $user->id)
            ->exists();
    }

    public function isFollowedBy(User $user)
    {
        return $this->followers()
            ->where('follower_id', $user->id)
            ->exists();
    }

    public function isAdmin()
    {
        return $this->role === 'admin';
    }
}
