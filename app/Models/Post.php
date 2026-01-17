<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id', 'content', 'caption', 'media_type', 'media_url', 
        'is_archived', 'published_at',
    ];

    protected $casts = [
        'published_at' => 'datetime',
        'is_archived' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = ['likes_count', 'comments_count', 'shares_count', 'is_liked_by_auth'];

    // Relationships

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function media()
    {
        return $this->hasMany(PostMedia::class)->orderBy('order');
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

    // Accessors

    public function getLikesCountAttribute()
    {
        return $this->likes()->count();
    }

    public function getCommentsCountAttribute()
    {
        return $this->comments()->count();
    }

    public function getSharesCountAttribute()
    {
        return $this->shares()->count();
    }

    public function getIsLikedByAuthAttribute()
    {
        if (!auth()->check()) {
            return false;
        }
        return $this->likes()
            ->where('user_id', auth()->id())
            ->exists();
    }

    // Query Scopes

    public function scopePublished($query)
    {
        return $query->whereNotNull('published_at')
            ->where('published_at', '<=', now());
    }

    public function scopeNotArchived($query)
    {
        return $query->where('is_archived', false);
    }

    public function scopeForAdmin($query)
    {
        return $query->whereHas('user', function ($q) {
            $q->where('role', 'admin');
        });
    }
}
