# Flutter & Backend Integration Guide

Complete guide for connecting your Flutter app to the Laravel backend API.

## 🔗 API Integration Overview

### Architecture
```
Flutter App
    ↓ (Dio HTTP Client)
Retrofit API Service
    ↓ (Automatic Serialization)
JSON Models (User, Post, Comment)
    ↓ (State Management)
Riverpod Providers
    ↓ (UI Updates)
Screens & Widgets
```

## 📡 Backend API Endpoints Reference

### Authentication
```
POST /api/login
POST /api/register
```

### Posts
```
GET    /api/posts              - Get public feed
GET    /api/posts/feed         - Get personalized feed
GET    /api/posts/{id}         - Get single post
POST   /api/posts              - Create post (admin only)
PUT    /api/posts/{id}         - Update post
DELETE /api/posts/{id}         - Delete post
```

### Engagement
```
POST   /api/posts/{id}/like    - Like post
POST   /api/posts/{id}/unlike  - Unlike post
GET    /api/posts/{id}/likes   - Get likes list
POST   /api/posts/{id}/share   - Share post
GET    /api/posts/{id}/shares  - Get shares
DELETE /api/shares/{id}        - Delete share
```

### Comments
```
GET    /api/posts/{id}/comments  - Get comments
POST   /api/posts/{id}/comments  - Create comment
PUT    /api/comments/{id}        - Update comment
DELETE /api/comments/{id}        - Delete comment
```

### Users
```
GET    /api/user/me                - Current user
GET    /api/user/{id}              - User profile
PUT    /api/user/profile           - Update profile
POST   /api/user/change-password   - Change password
POST   /api/user/{id}/follow       - Follow user
POST   /api/user/{id}/unfollow     - Unfollow user
GET    /api/user/{id}/followers    - Get followers
GET    /api/user/{id}/following    - Get following
GET    /api/user/search            - Search users
POST   /api/update-fcm-token       - Update FCM token
```

## 🚀 Step-by-Step Integration

### Step 1: Configure API Endpoint

**File**: `lib/config/api_config.dart`

```dart
class ApiConfig {
  // For development - use your machine's IP
  static const String _baseUrl = 'http://192.168.1.100:8000';
  
  // For production - use your domain
  // static const String _baseUrl = 'https://api.yourdomain.com';

  static String get baseUrl => _baseUrl;
  static String get apiBaseUrl => '$_baseUrl/api';
  // ...
}
```

**Finding Your Machine IP:**
```bash
# macOS
ipconfig getifaddr en0

# Linux
hostname -I

# Windows (PowerShell)
ipconfig
```

### Step 2: Start Your Backend Server

```bash
cd /Users/saranga/vs\ code\ projects/project-mla

# Run migrations (first time)
php artisan migrate

# Start Laravel development server
php artisan serve --host=0.0.0.0 --port=8000
```

The server will be available at `http://YOUR_IP:8000`

### Step 3: Test Authentication

#### Create Test User (via Tinker)
```bash
php artisan tinker

# Create test user
User::create([
    'name' => 'Test User',
    'email' => 'test@example.com',
    'password' => bcrypt('password123'),
    'is_admin' => true,
]);
```

#### Or Register via App
1. Open Flutter app
2. Go to Register screen
3. Create account with:
   - Name: Test User
   - Email: test@example.com
   - Password: password123

### Step 4: Test API Endpoints

#### Using cURL
```bash
# Register
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'

# Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'

# Get posts (with token)
curl -X GET http://localhost:8000/api/posts \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Using Postman
1. Import collection: `API_ENDPOINTS.postman_collection.json`
2. Set `base_url` variable
3. Set `token` after login
4. Test endpoints

### Step 5: Handle Authentication Flow

**Login Flow:**
```
1. User enters email & password
2. POST /api/login
3. Backend returns: { token, user }
4. App saves token to Hive storage
5. Tokens automatically added to future requests
6. Redirect to home screen
```

**Logout Flow:**
```
1. User clicks logout
2. Clear token from storage
3. Clear user data
4. Redirect to login
5. Next request will be 401 → auto logout
```

## 📝 Model Serialization

### Auto-Generated Models
The app uses `json_serializable` for automatic JSON serialization:

```bash
# Generate serialization code
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch
```

This generates `*.g.dart` files with:
- `fromJson()` - JSON to Dart
- `toJson()` - Dart to JSON

### Example Request/Response

**Request:**
```json
{
  "body": "Nice post!",
  "parent_comment_id": null
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "post_id": 1,
    "user_id": 1,
    "body": "Nice post!",
    "parent_comment_id": null,
    "user": {
      "id": 1,
      "name": "John",
      "email": "john@example.com",
      "avatar": "https://...",
      "is_verified": false,
      "is_admin": false
    },
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T10:00:00Z"
  }
}
```

## 🔐 Token Management

### Automatic Token Handling

**File**: `lib/data/providers/http_provider.dart`

```dart
// Tokens automatically added to requests
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = StorageService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ),
);
```

### Manual Token Operations

```dart
// Save token after login
await StorageService.saveToken(token);

// Get token for debugging
final token = StorageService.getToken();

// Clear token on logout
await StorageService.logout();
```

## 🔄 State Synchronization

### Automatic Cache Invalidation

When user performs actions, caches are automatically invalidated:

```dart
// After liking a post
await apiService.likePost(postId);
ref.invalidate(postProvider(postId));  // Refresh post
ref.invalidate(feedProvider);          // Refresh feed

// After creating comment
await apiService.createComment(postId, data);
ref.invalidate(commentsProvider(postId));  // Refresh comments
```

### Manual Refresh

```dart
// Refresh posts feed
ref.refresh(feedProvider);

// Refresh user profile
ref.refresh(userProfileProvider(userId));
```

## 🚨 Error Handling

### API Errors

**File**: `lib/data/providers/http_provider.dart`

```dart
// Automatic error handling
dio.interceptors.add(
  InterceptorsWrapper(
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        // Unauthorized - logout user
        StorageService.logout();
      }
      if (error.response?.statusCode == 403) {
        // Forbidden - show permission error
        showSnackBar('You don\'t have permission');
      }
      return handler.next(error);
    },
  ),
);
```

### Response Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | OK | Process response |
| 201 | Created | Show success |
| 400 | Bad Request | Show form error |
| 401 | Unauthorized | Logout |
| 403 | Forbidden | Show permission error |
| 404 | Not Found | Show not found error |
| 500 | Server Error | Show error message |

## 🧪 Testing Integration

### Test Scenario 1: Complete User Journey

```
1. Start app
2. Register new account
3. Login
4. View feed
5. Create post (if admin)
6. Like a post
7. Add comment
8. Follow user
9. View profile
10. Logout
```

### Test Scenario 2: Error Handling

```
1. Try login with wrong password
2. Try create post without auth
3. Try delete someone else's post
4. Try upload huge file
5. Test with no network
6. Test with invalid token
```

### Test Scenario 3: Performance

```
1. Load feed with many posts
2. Scroll through long comment list
3. Upload multiple media files
4. Search users with many results
5. Check app memory usage
```

## 🔗 Common Integration Issues

### Issue: 401 Unauthorized on Every Request
**Cause**: Token not being sent  
**Solution**:
```bash
# Check token is saved
flutter logs | grep "token"

# Verify Dio interceptor is set up correctly
# Check API_SERVICE has Authorization header
```

### Issue: CORS Errors
**Cause**: Backend not accepting requests from app origin  
**Solution**:
```php
// In Laravel config/cors.php
'allowed_origins' => ['*'],
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

### Issue: Image URLs Not Loading
**Cause**: Images stored with relative paths  
**Solution**:
```php
// In Laravel Controller
'avatar_url' => $user->avatar ? url('storage/' . $user->avatar) : null,
'media_url' => url('storage/' . $media->path),
```

### Issue: Large File Uploads Timeout
**Cause**: Default timeout too short  
**Solution**:
```dart
// In ApiConfig
static const Duration connectTimeout = Duration(seconds: 60);
static const Duration receiveTimeout = Duration(seconds: 60);
```

### Issue: Pagination Not Working
**Cause**: Wrong parameter names  
**Solution**:
```dart
// Correct parameter names
final response = await apiService.getPosts(
  page: 1,      // Not 'p' or 'page_num'
  perPage: 15,  // Not 'per_page' or 'limit'
);
```

## 📊 Monitoring API Calls

### Enable Detailed Logging

**Add to main.dart:**
```dart
import 'package:dio/dio.dart';

void main() {
  // Setup Dio with logging
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(
    responseBody: true,
    requestBody: true,
    error: true,
    requestHeader: true,
    responseHeader: true,
  ));
  
  runApp(const SocialMediaApp());
}
```

### Check API Response Format

**Add print statement in providers:**
```dart
final response = await apiService.getPosts(page, 15);
print('Response: ${response.data}');  // See actual response
return data.map((json) => Post.fromJson(json)).toList();
```

## 🔧 Debugging Tools

### 1. Flutter DevTools
```bash
flutter pub global activate devtools
devtools

# In another terminal
flutter run --observe

# Copy observe URL to DevTools
```

### 2. Postman for Backend Testing
- Test API endpoints independently
- Verify response structure
- Check error scenarios

### 3. Network Tab in Browser DevTools
- Monitor API calls
- Check request/response headers
- Verify authentication headers

## 📚 Integration Checklist

- [ ] Backend server running
- [ ] API base URL configured
- [ ] Firebase credentials set
- [ ] Test user account created
- [ ] Login works
- [ ] Feed loads posts
- [ ] Like/unlike works
- [ ] Comments work
- [ ] User search works
- [ ] Profile loads correctly
- [ ] Follow/unfollow works
- [ ] Image upload works
- [ ] Error handling works
- [ ] Logout works
- [ ] App handles offline mode

## 🚀 Production Deployment

### Backend Production Setup
```bash
# Build for production
php artisan config:cache
php artisan route:cache

# Set environment
APP_ENV=production
APP_DEBUG=false

# Serve with production server
php artisan serve --host=0.0.0.0 --port=8000
# Or use Nginx/Apache
```

### Flutter Production Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Update API Configuration
```dart
// Change to production domain
static const String _baseUrl = 'https://api.yourdomain.com';
```

## 📖 Additional Resources

- Backend Documentation: See `FLUTTER_INTEGRATION.md` in backend
- API Reference: See `API_DOCUMENTATION.md`
- Architecture Guide: See `ARCHITECTURE.md`

---

**Version**: 1.0  
**Last Updated**: January 17, 2025
