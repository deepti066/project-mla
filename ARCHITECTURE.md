# 🏗️ Social Media Platform - Architecture & Design Document

## Executive Summary

This document outlines the architectural design for a scalable, production-ready social media platform API built with Laravel 12 and PHP 8.2. The platform supports admin-posted content with user engagement features (likes, comments, shares, follows).

---

## 1. System Architecture Overview

### Architecture Pattern: **REST API with Service-Oriented Design**

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTPS
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  API Gateway / Middleware                    │
│     (CORS, Rate Limiting, Request Validation)              │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌──────────────────┐     ┌──────────────────┐
│   Controllers    │     │   Middleware     │
│  (HTTP Layer)    │     │  (Auth, Logging) │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│    Service Layer                 │
│  - Business Logic                │
│  - Data Transformation           │
└────────────┬─────────────────────┘
             │
     ┌───────┴───────┐
     ▼               ▼
┌──────────┐  ┌──────────────┐
│  Models  │  │ Repositories │
└────┬─────┘  └──────────────┘
     │
     ▼
┌────────────────────────────────────┐
│      Database Layer                │
│  - Laravel Eloquent ORM            │
│  - Query Building                  │
└────────────┬───────────────────────┘
             │
             ▼
┌────────────────────────────────────┐
│      PostgreSQL/MySQL Database     │
│  - Relational Data Storage         │
└────────────────────────────────────┘

┌──────────────────────────────────────────┐
│         External Services                │
│  - Firebase (Push Notifications)        │
│  - Cloud Storage (Media Files)           │
│  - Email Service                        │
└──────────────────────────────────────────┘
```

---

## 2. Database Schema Design

### Entity Relationship Diagram

```
┌─────────────┐
│   users     │
├─────────────┤
│ id (PK)     │◄─────────┐
│ name        │          │
│ email       │    ┌─────┴──────┐
│ password    │    │            │
│ role        │    ▼            ▼
│ bio         │  ┌──────┐  ┌──────────┐
│ avatar_url  │  │posts │  │ follows  │
│ fcm_token   │  ├──────┤  ├──────────┤
│ is_verified │  │ id   │  │ id       │
│ is_private  │  │ user │  │ follower │
│ deleted_at  │  │ id   │  │ id       │
└─────────────┘  │      │  │ following│
                 │      │  │ id       │
                 ▼      ▼  └──────────┘
            ┌───────────────────┐
            │   post_media      │
            ├───────────────────┤
            │ id                │
            │ post_id (FK)      │
            │ media_type        │
            │ media_url         │
            │ thumbnail_url     │
            │ order             │
            └───────────────────┘
                     ▲
                     │
            ┌─────────┴──────────┐
            ▼                    ▼
        ┌─────────┐         ┌──────────┐
        │ comments│         │  likes   │
        ├─────────┤         ├──────────┤
        │ id      │         │ id       │
        │ user_id │         │ user_id  │
        │ post_id │         │ post_id  │
        │ parent  │         │ unique   │
        │ body    │         │ constraint│
        └─────────┘         └──────────┘
                    ▼
            ┌─────────────┐
            │   shares    │
            ├─────────────┤
            │ id          │
            │ user_id     │
            │ post_id     │
            │ shared_to   │
            └─────────────┘
```

### Key Design Decisions

1. **Soft Deletes**: Posts, Comments, and Users support soft deletes for data preservation
2. **Unique Constraints**: 
   - Users can't follow the same person twice
   - Users can't like the same post twice
   - Users can't like themselves
3. **Ordered Media**: `post_media` table maintains order of multiple media items
4. **Nested Comments**: Comments can have parent_comment_id for reply threads
5. **Engagement Tracking**: Separate tables for likes, comments, shares for flexible querying

---

## 3. Core Models & Relationships

### User Model
```
User
├── hasMany: posts
├── hasMany: comments
├── hasMany: likes
├── hasMany: views
├── hasMany: shares
├── hasMany: followers (through Follow table)
├── hasMany: following (through Follow table)
└── Methods: isFollowing(), isFollowedBy(), followersCount()
```

### Post Model
```
Post
├── belongsTo: user
├── hasMany: media (PostMedia)
├── hasMany: comments
├── hasMany: likes
├── hasMany: views
├── hasMany: shares
├── Scopes: published(), notArchived(), forAdmin()
├── Accessors: likes_count, comments_count, shares_count, is_liked_by_auth
└── Methods: track engagement dynamically
```

### Comment Model
```
Comment (with SoftDeletes)
├── belongsTo: user
├── belongsTo: post
├── belongsTo: parentComment (self-referential)
├── hasMany: replies (self-referential)
└── Supports nested threaded comments
```

### Like, Follow, Share, PostMedia Models
- Simple pivot-like structures
- Lightweight with minimal logic
- Support eager loading

---

## 4. API Design Principles

### RESTful Conventions

```
Verb    Endpoint                    Action
────────────────────────────────────────────────
POST    /api/posts                  Create post (admin)
GET     /api/posts                  List all posts
GET     /api/posts/feed             Get personalized feed
GET     /api/posts/{id}             Get single post
PUT     /api/posts/{id}             Update post (admin)
DELETE  /api/posts/{id}             Delete post (admin)

POST    /api/posts/{id}/like        Like a post
POST    /api/posts/{id}/unlike      Unlike a post
GET     /api/posts/{id}/likes       Get likes list

POST    /api/posts/{id}/comments    Create comment
GET     /api/posts/{id}/comments    List comments
PUT     /api/comments/{id}          Update comment
DELETE  /api/comments/{id}          Delete comment

POST    /api/posts/{id}/share       Share post
GET     /api/posts/{id}/shares      Get shares list
DELETE  /api/shares/{id}            Remove share

POST    /api/user/{id}/follow       Follow user
POST    /api/user/{id}/unfollow     Unfollow user
GET     /api/user/{id}/followers    Get followers
GET     /api/user/{id}/following    Get following
GET     /api/user/search            Search users
```

### Response Format

**Success Response (200/201):**
```json
{
  "message": "Operation successful",
  "data": { /* payload */ }
}
```

**Paginated Response:**
```json
{
  "data": [ /* items */ ],
  "pagination": {
    "total": 100,
    "current_page": 1,
    "per_page": 15,
    "last_page": 7,
    "has_more": true
  }
}
```

**Error Response (4xx/5xx):**
```json
{
  "message": "Error description",
  "errors": { /* validation errors */ }
}
```

---

## 5. Authentication & Authorization

### Authentication Strategy: **Laravel Sanctum**

- Token-based authentication
- Lightweight alternative to OAuth
- Perfect for SPAs and mobile apps
- Supports multiple tokens per user

### Authorization Strategy: **Role-Based Access Control (RBAC)**

```
Roles:
├── admin
│   ├── Create posts with media
│   ├── Edit/delete own posts
│   └── Cannot like/comment (optional: can be changed)
└── follower
    ├── Like posts
    ├── Comment on posts
    ├── Share posts
    ├── Follow other users
    └── View feed
```

### Implementation

```php
// Middleware-based authorization
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/posts', [PostController::class, 'store'])
        ->middleware('admin'); // Admin-only check
});

// Controller-level authorization
if (!$request->user()->isAdmin()) {
    return response()->json(['message' => 'Unauthorized'], 403);
}
```

---

## 6. Scalability Considerations

### Current Implementation

**For 0-100K users:**
- Single MySQL/PostgreSQL instance
- File storage on local/S3
- In-memory caching (Redis optional)
- Standard Laravel structure

### Future Scaling (100K+ users)

1. **Database Optimization**
   - Read replicas for high-read operations
   - Database indexing on frequently queried columns
   - Partitioning large tables (likes, comments, views)
   - Query optimization and profiling

2. **Caching Layer**
   - Redis for session/token caching
   - Cache user profiles frequently
   - Cache post feeds
   - Implement cache invalidation strategies

3. **CDN for Media**
   - CloudFront / CloudFlare for image/video delivery
   - Lazy loading for media
   - Image optimization (WebP, different sizes)

4. **Search & Analytics**
   - Elasticsearch for post/user search
   - Separate analytics database
   - Real-time notification queue (RabbitMQ/Redis)

5. **Microservices (Phase 2)**
   - Notification service
   - Media processing service
   - Analytics service
   - Search service

### Performance Optimizations

```php
// Eager loading to prevent N+1 queries
Post::with(['user', 'media', 'likes', 'comments.user'])
    ->latest()
    ->paginate(15);

// Database indexing strategy
Schema::create('likes', function (Blueprint $table) {
    $table->index(['user_id', 'post_id']); // Composite index
    $table->index(['post_id', 'created_at']); // For sorting
});

// Query caching
Cache::remember('post.'. $postId, 3600, function () {
    return Post::find($postId);
});
```

---

## 7. File Upload & Media Management

### Strategy: **Cloud Storage (S3) with Local Fallback**

```php
// File Upload Flow
User → Validate → Store to S3 → Get URL → Save to DB → Return response

// Storage Structure
storage/
├── posts/
│   ├── {post_id}/
│   │   ├── {uuid}_original.jpg
│   │   ├── {uuid}_thumbnail.jpg
│   │   └── {uuid}_optimized.jpg
├── avatars/
│   └── {user_id}/
│       └── {uuid}.jpg
```

### Media Processing

**Immediate (Synchronous):**
- Upload to S3
- Generate basic metadata
- Save to database

**Deferred (Asynchronous via Queue):**
- Generate video thumbnail
- Optimize images (multiple sizes)
- Generate WebP versions
- Run virus scan

### Limits

- Max file size: 100MB
- Max files per post: 10
- Supported formats: jpg, jpeg, png, gif, mp4, mov

---

## 8. Notifications Strategy

### Push Notifications (Firebase Cloud Messaging)

**Events Triggering Notifications:**
1. Someone likes your post
2. Someone comments on your post
3. Someone replies to your comment
4. Someone starts following you
5. Someone shares your post

### Implementation

```php
// Queue job for notification
dispatch(new SendPostLikeNotification($post, $user));

// Notification service
class NotificationService {
    public function sendPushNotification(User $user, string $title, string $body) {
        // Use kreait/firebase-php
    }
}
```

---

## 9. Security Considerations

### 1. Authentication & Authorization
- ✅ Sanctum token-based auth
- ✅ HTTPS only
- ✅ Role-based access control
- ✅ Token rotation on sensitive operations

### 2. Input Validation
- ✅ Server-side validation on all inputs
- ✅ Sanitize string inputs
- ✅ Validate file types and sizes
- ✅ Rate limiting on auth endpoints

### 3. Data Protection
- ✅ Passwords hashed (bcrypt)
- ✅ Sensitive data hidden from responses (FCM tokens)
- ✅ Soft deletes for data preservation
- ✅ GDPR compliance (right to deletion)

### 4. API Security
- ✅ CORS properly configured
- ✅ Rate limiting per user/IP
- ✅ SQL injection prevention (Eloquent ORM)
- ✅ CSRF protection (Sanctum)

### 5. File Security
- ✅ Validate MIME types
- ✅ Store uploads outside web root
- ✅ Use signed URLs for downloads
- ✅ Antivirus scanning for uploads

---

## 10. Testing Strategy

### Unit Tests
```php
// Test Model relationships
public function test_user_has_many_posts() {
    $user = User::factory()->create();
    $user->posts()->create([...]);
    $this->assertCount(1, $user->posts);
}

// Test business logic
public function test_user_can_like_post() {
    $post = Post::factory()->create();
    $user = User::factory()->create();
    // ... test like operation
}
```

### Feature Tests
```php
// Test API endpoints
public function test_can_create_post() {
    $response = $this->post('/api/posts', [
        'caption' => 'Test post',
        'media' => [/* files */]
    ]);
    $response->assertStatus(201);
}
```

### Test Coverage Goals
- Controllers: 80%+
- Models: 90%+
- Services: 85%+

---

## 11. Deployment & DevOps

### Environment Setup

**Development:**
- Local Laravel server (`php artisan serve`)
- SQLite or local MySQL
- File storage: local

**Staging:**
- AWS/DigitalOcean Ubuntu 22.04
- MySQL 8.0
- S3 for file storage
- Redis for caching

**Production:**
- Multi-server load balancer
- Managed MySQL (RDS/CloudSQL)
- CDN for media
- Auto-scaling groups

### Deployment Steps

1. Push to Git repository
2. CI/CD pipeline (GitHub Actions/GitLab CI)
3. Run tests
4. Build Docker image
5. Push to container registry
6. Deploy to Kubernetes/Docker Swarm

---

## 12. Monitoring & Logging

### Logging Strategy

```php
// Structured logging
Log::info('Post created', [
    'user_id' => $user->id,
    'post_id' => $post->id,
    'media_count' => $post->media()->count(),
    'duration' => microtime(true) - $startTime,
]);

// Error logging
Log::error('Media upload failed', [
    'user_id' => $user->id,
    'file_size' => $file->getSize(),
    'error' => $exception->getMessage(),
]);
```

### Monitoring Metrics

- API response time
- Database query time
- Cache hit rate
- Failed authentication attempts
- File upload success rate
- Storage usage
- Concurrent users

### Tools
- Laravel Telescope (development)
- Sentry (error tracking)
- DataDog/New Relic (production monitoring)
- CloudWatch (AWS logs)

---

## 13. Future Enhancement Roadmap

### Phase 1 (Current)
- ✅ Posts with multiple media
- ✅ Comments with nesting
- ✅ Likes & Shares
- ✅ Follow system
- ✅ User profiles

### Phase 2 (Next)
- [ ] Video transcoding & thumbnail generation
- [ ] Push notifications (real-time)
- [ ] Search with Elasticsearch
- [ ] Hashtag support & trending
- [ ] Stories feature
- [ ] Direct messaging

### Phase 3 (Later)
- [ ] Live streaming
- [ ] Advanced analytics dashboard
- [ ] Recommendation algorithm
- [ ] Content moderation (ML)
- [ ] Multiple languages
- [ ] Accessibility features

---

## 14. Code Quality Standards

### Style Guide: **PSR-12**

```php
// Use type hints
public function store(Request $request): JsonResponse {
    // ...
}

// Use strict types
declare(strict_types=1);

// Meaningful variable names
$postsWithEngagement = collect();
```

### Tools
- Laravel Pint (code formatting)
- PHPStan (static analysis)
- Pest (testing framework)

---

## 15. Configuration Checklist

Before deployment, ensure:

- [ ] Database migrations run successfully
- [ ] Storage disk configured (local/S3)
- [ ] Firebase credentials loaded
- [ ] Email service configured
- [ ] Redis cache configured
- [ ] Rate limiting configured
- [ ] CORS origins whitelisted
- [ ] Environment variables secured
- [ ] SSL certificates installed
- [ ] Backup strategy implemented
- [ ] Monitoring setup
- [ ] Error tracking configured
- [ ] Load balancer configured
- [ ] CDN configured for media

---

## Conclusion

This architecture provides a **scalable, secure, and maintainable** foundation for a modern social media platform. The design prioritizes:

- **User Experience**: Fast API responses with pagination
- **Security**: Authentication, validation, and authorization
- **Scalability**: Database optimization, caching, CDN
- **Maintainability**: Clear code structure, testing, documentation
- **Reliability**: Error handling, logging, monitoring

The system is ready for production with 0-500K users. Additional optimization needed for larger scales (millions of users) involves database sharding, distributed caching, and microservices architecture.

---

**Document Version**: 1.0  
**Last Updated**: January 17, 2025  
**Author**: AI Software Architect
