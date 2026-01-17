# 🚀 Social Media Platform API Documentation

## Overview

This is a production-ready Laravel API for a social media platform where:
- **Admins** post content (images/videos with captions)
- **Users** can like, comment, share posts, and follow each other
- Complete engagement tracking and analytics

---

## 📋 Table of Contents

1. [Authentication](#authentication)
2. [User Management](#user-management)
3. [Posts](#posts)
4. [Comments](#comments)
5. [Likes](#likes)
6. [Shares](#shares)
7. [Follow System](#follow-system)
8. [Analytics](#analytics)
9. [Error Handling](#error-handling)

---

## Authentication

### Register User

**Endpoint:** `POST /api/register`

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "admin" // or "follower"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "access_token": "abc123xyz",
  "token_type": "Bearer",
  "role": "admin"
}
```

### Login

**Endpoint:** `POST /api/login`

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "access_token": "abc123xyz",
  "token_type": "Bearer",
  "role": "admin"
}
```

### Update FCM Token

**Endpoint:** `POST /api/update-fcm-token` (Protected)

```json
{
  "fcm_token": "device_token_here"
}
```

**Response (200):**
```json
{
  "message": "FCM token updated"
}
```

---

## User Management

### Get Current User Profile

**Endpoint:** `GET /api/user/me` (Protected)

**Response (200):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "avatar": "https://...",
  "bio": "Software developer",
  "role": "admin",
  "is_verified": true,
  "is_private": false,
  "stats": {
    "posts_count": 15,
    "followers_count": 1250,
    "following_count": 340
  },
  "last_seen_at": "2025-01-17T10:30:00Z"
}
```

### Get User Profile by ID

**Endpoint:** `GET /api/user/{userId}` (Protected)

**Response (200):**
```json
{
  "id": 2,
  "name": "Jane Smith",
  "email": "jane@example.com",
  "avatar": "https://...",
  "bio": "Content creator",
  "role": "follower",
  "is_verified": true,
  "is_private": false,
  "stats": {
    "posts_count": 45,
    "followers_count": 5000,
    "following_count": 200
  },
  "is_following": false,
  "is_followed_by": true,
  "last_seen_at": "2025-01-17T15:45:00Z"
}
```

### Update User Profile

**Endpoint:** `PUT /api/user/profile` (Protected)

```json
{
  "name": "John Updated",
  "bio": "Updated bio",
  "is_private": false
}
```

With avatar (multipart/form-data):
```
name: John Updated
bio: Updated bio
avatar: <file>
is_private: false
```

**Response (200):**
```json
{
  "message": "Profile updated successfully",
  "user": { /* user object */ }
}
```

### Change Password

**Endpoint:** `POST /api/user/change-password` (Protected)

```json
{
  "current_password": "password123",
  "new_password": "newpassword456",
  "new_password_confirmation": "newpassword456"
}
```

**Response (200):**
```json
{
  "message": "Password changed successfully"
}
```

### Follow User

**Endpoint:** `POST /api/user/{userId}/follow` (Protected)

**Response (200):**
```json
{
  "message": "User followed successfully",
  "followers_count": 1251
}
```

### Unfollow User

**Endpoint:** `POST /api/user/{userId}/unfollow` (Protected)

**Response (200):**
```json
{
  "message": "User unfollowed successfully",
  "followers_count": 1250
}
```

### Get User's Followers

**Endpoint:** `GET /api/user/{userId}/followers?page=1&per_page=20` (Protected)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "avatar": "https://...",
      "is_verified": true,
      "bio": "Software developer"
    }
  ],
  "pagination": {
    "total": 100,
    "current_page": 1,
    "per_page": 20
  }
}
```

### Get User's Following

**Endpoint:** `GET /api/user/{userId}/following?page=1&per_page=20` (Protected)

**Response (200):**
Similar to followers endpoint

### Search Users

**Endpoint:** `GET /api/user/search?q=john&page=1&per_page=15` (Protected)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "avatar": "https://...",
      "is_verified": true,
      "bio": "Software developer"
    }
  ],
  "pagination": {
    "total": 50,
    "current_page": 1,
    "per_page": 15
  }
}
```

---

## Posts

### Create Post (Admin Only)

**Endpoint:** `POST /api/posts` (Protected, Admin only)

```
POST /api/posts
Content-Type: multipart/form-data

caption: "Check out my new post!"
media: [file1.jpg, file2.mp4]
```

**Response (201):**
```json
{
  "message": "Post created successfully",
  "post": {
    "id": 42,
    "user": {
      "id": 1,
      "name": "John Doe",
      "avatar": "https://...",
      "is_verified": true
    },
    "caption": "Check out my new post!",
    "media": [
      {
        "id": 1,
        "type": "image",
        "url": "https://storage.../post_1_0.jpg",
        "thumbnail": null
      },
      {
        "id": 2,
        "type": "video",
        "url": "https://storage.../post_1_1.mp4",
        "thumbnail": "https://storage.../post_1_1_thumb.jpg"
      }
    ],
    "engagement": {
      "likes_count": 0,
      "comments_count": 0,
      "shares_count": 0,
      "views_count": 0
    },
    "is_liked": false,
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T10:00:00Z"
  }
}
```

### Get Public Feed (All Users)

**Endpoint:** `GET /api/posts?page=1&per_page=15` (Protected)

**Response (200):**
```json
{
  "data": [
    {
      "id": 42,
      "user": { /* user object */ },
      "caption": "My awesome post",
      "media": [ /* array of media objects */ ],
      "engagement": {
        "likes_count": 150,
        "comments_count": 25,
        "shares_count": 10,
        "views_count": 5000
      },
      "is_liked": true,
      "created_at": "2025-01-17T10:00:00Z",
      "updated_at": "2025-01-17T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 500,
    "current_page": 1,
    "per_page": 15,
    "last_page": 34,
    "has_more": true
  }
}
```

### Get Personalized Feed (Following)

**Endpoint:** `GET /api/posts/feed?page=1&per_page=15` (Protected)

Returns posts from users that the authenticated user follows + own posts.

**Response (200):** Same structure as public feed

### Get Single Post

**Endpoint:** `GET /api/posts/{postId}` (Protected)

**Response (200):** Single post object (same structure)

### Update Post (Admin Only)

**Endpoint:** `PUT /api/posts/{postId}` (Protected, Admin only)

```json
{
  "caption": "Updated caption",
  "is_archived": false
}
```

**Response (200):**
```json
{
  "message": "Post updated successfully",
  "post": { /* post object */ }
}
```

### Delete Post (Admin Only)

**Endpoint:** `DELETE /api/posts/{postId}` (Protected, Admin only)

**Response (200):**
```json
{
  "message": "Post deleted successfully"
}
```

---

## Comments

### Get Comments for a Post

**Endpoint:** `GET /api/posts/{postId}/comments?page=1&per_page=20` (Protected)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "user": {
        "id": 2,
        "name": "Jane Smith",
        "avatar": "https://...",
        "is_verified": true
      },
      "body": "Great post!",
      "replies": [ /* nested comment objects */ ],
      "created_at": "2025-01-17T10:30:00Z",
      "updated_at": "2025-01-17T10:30:00Z"
    }
  ],
  "pagination": {
    "total": 50,
    "current_page": 1,
    "per_page": 20
  }
}
```

### Create Comment

**Endpoint:** `POST /api/posts/{postId}/comments` (Protected)

```json
{
  "body": "This is a great post!",
  "parent_comment_id": null
}
```

For reply to comment, include parent_comment_id:
```json
{
  "body": "Thanks for the comment!",
  "parent_comment_id": 1
}
```

**Response (201):**
```json
{
  "message": "Comment created successfully",
  "comment": { /* comment object */ }
}
```

### Update Comment

**Endpoint:** `PUT /api/comments/{commentId}` (Protected, Own comments only)

```json
{
  "body": "Updated comment text"
}
```

**Response (200):**
```json
{
  "message": "Comment updated successfully",
  "comment": { /* comment object */ }
}
```

### Delete Comment

**Endpoint:** `DELETE /api/comments/{commentId}` (Protected, Own comments only)

**Response (200):**
```json
{
  "message": "Comment deleted successfully"
}
```

---

## Likes

### Like a Post

**Endpoint:** `POST /api/posts/{postId}/like` (Protected)

**Response (200):**
```json
{
  "message": "Post liked successfully",
  "likes_count": 151
}
```

### Unlike a Post

**Endpoint:** `POST /api/posts/{postId}/unlike` (Protected)

**Response (200):**
```json
{
  "message": "Like removed successfully",
  "likes_count": 150
}
```

### Get Likes for a Post

**Endpoint:** `GET /api/posts/{postId}/likes?page=1` (Protected)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "avatar": "https://...",
      "username": "john@example.com"
    }
  ],
  "pagination": {
    "total": 150,
    "current_page": 1
  }
}
```

---

## Shares

### Share a Post

**Endpoint:** `POST /api/posts/{postId}/share` (Protected)

```json
{
  "shared_to": "story"
}
```

Options for `shared_to`:
- `null` (generic share)
- `"story"` (share to story)
- `"direct_message"` (share via DM)
- `"feed"` (repost to feed)

**Response (200):**
```json
{
  "message": "Post shared successfully",
  "shares_count": 11
}
```

### Get Shares for a Post

**Endpoint:** `GET /api/posts/{postId}/shares?page=1&per_page=50` (Protected)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "user": {
        "id": 1,
        "name": "John Doe",
        "avatar": "https://..."
      },
      "shared_to": "story",
      "created_at": "2025-01-17T10:30:00Z"
    }
  ],
  "pagination": {
    "total": 10,
    "current_page": 1
  }
}
```

### Remove Share

**Endpoint:** `DELETE /api/shares/{shareId}` (Protected, Own shares only)

**Response (200):**
```json
{
  "message": "Share removed successfully"
}
```

---

## Follow System

See [User Management](#user-management) section for follow-related endpoints.

---

## Analytics

### Get Analytics

**Endpoint:** `GET /api/analytics` (Protected)

**Response (200):**
```json
{
  "total_posts": 45,
  "total_likes": 2500,
  "total_comments": 350,
  "total_views": 15000,
  "total_shares": 280,
  "average_engagement_rate": 18.5
}
```

### Record View

**Endpoint:** `POST /api/views` (Protected)

```json
{
  "post_id": 42
}
```

**Response (200):**
```json
{
  "message": "View recorded"
}
```

---

## Error Handling

### Common Error Responses

**401 Unauthorized:**
```json
{
  "message": "Unauthenticated"
}
```

**403 Forbidden:**
```json
{
  "message": "Unauthorized"
}
```

**404 Not Found:**
```json
{
  "message": "Post not found"
}
```

**422 Unprocessable Entity (Validation Error):**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "caption": ["The caption field is required."],
    "media": ["The media must be an array."]
  }
}
```

**400 Bad Request:**
```json
{
  "message": "You have already liked this post"
}
```

---

## Request Headers

All authenticated requests must include:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

For multipart requests (file uploads):
```
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

---

## Pagination

Endpoints supporting pagination accept:
- `page` - Page number (default: 1)
- `per_page` - Items per page (default varies, max: 50)

Example: `GET /api/posts?page=2&per_page=20`

Pagination response includes:
- `total` - Total items
- `current_page` - Current page number
- `per_page` - Items per page
- `last_page` - Last page number (if available)
- `has_more` - Boolean indicating more pages available

---

## Best Practices for Flutter Integration

1. **Store the access token securely** using `flutter_secure_storage`
2. **Implement token refresh logic** before token expiration
3. **Handle 401 errors** by redirecting to login
4. **Show pagination indicators** for better UX
5. **Cache media files** locally for offline viewing
6. **Use WebSocket or Server-Sent Events** for real-time notifications
7. **Implement image/video compression** before upload
8. **Handle slow network** with appropriate timeout values

---

## Future Enhancements

- [ ] Video thumbnail generation via FFmpeg
- [ ] Push notifications for engagement
- [ ] Hashtag support and trending
- [ ] Post scheduling
- [ ] Story feature
- [ ] Direct messaging
- [ ] Report/Block functionality
- [ ] Spam detection
- [ ] Advanced analytics dashboard
- [ ] Rate limiting
- [ ] Caching layer (Redis)
- [ ] Search indexing (Elasticsearch)
