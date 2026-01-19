# Flutter App - Social Media Platform

A modern, feature-rich social media mobile application built with Flutter, Riverpod state management, and Dio HTTP client.

## 📱 Features

- **Authentication**: Login & Registration with email/password
- **Feed**: Public posts feed and personalized following feed
- **Posts**: Create, edit, delete posts with multiple media (images/videos)
- **Engagement**: Like, comment, and share posts
- **Social**: Follow/unfollow users, view profiles
- **Search**: Find and discover users
- **Notifications**: Firebase push notifications (ready)
- **Offline Support**: Local storage with Hive

## 🛠️ Tech Stack

- **Framework**: Flutter 3.13+
- **State Management**: Riverpod 2.4+
- **HTTP Client**: Dio 5.4+
- **API Client**: Retrofit 4.1+
- **Local Storage**: Hive 2.2+
- **Push Notifications**: Firebase Messaging
- **Routing**: Go Router 12.1+
- **UI**: Material 3, Google Fonts

## 📁 Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── config/
│   │   ├── api_config.dart               # API configuration
│   │   ├── theme/
│   │   │   └── app_theme.dart           # Theme configuration
│   │   └── routes/
│   │       └── app_router.dart          # Navigation setup
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart          # User data model
│   │   │   ├── post_model.dart          # Post data model
│   │   │   └── comment_model.dart       # Comment data model
│   │   ├── providers/
│   │   │   ├── http_provider.dart       # HTTP client setup
│   │   │   ├── auth_provider.dart       # Auth state management
│   │   │   ├── post_provider.dart       # Post state management
│   │   │   ├── comment_provider.dart    # Comment state management
│   │   │   └── user_provider.dart       # User state management
│   │   └── services/
│   │       ├── api_service.dart         # API service (Retrofit)
│   │       └── storage_service.dart     # Local storage service
│   └── presentation/
│       ├── screens/
│       │   ├── splash_screen.dart
│       │   ├── auth/
│       │   │   ├── login_screen.dart
│       │   │   └── register_screen.dart
│       │   ├── home/
│       │   │   └── home_screen.dart
│       │   ├── post/
│       │   │   ├── create_post_screen.dart
│       │   │   └── post_detail_screen.dart
│       │   ├── profile/
│       │   │   ├── profile_screen.dart
│       │   │   └── edit_profile_screen.dart
│       │   └── search/
│       │       └── search_screen.dart
│       └── widgets/
│           └── post_card.dart            # Reusable post card widget
├── pubspec.yaml                          # Dependencies
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.13.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for emulator/device)
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build
   ```

   Or watch for changes:
   ```bash
   flutter pub run build_runner watch
   ```

4. **Setup Firebase**
   - Download your Google Services JSON files
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

5. **Update API Configuration**
   Edit `lib/config/api_config.dart`:
   ```dart
   static const String _baseUrl = 'http://YOUR_API_URL:8000';
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screens Overview

### Authentication
- **Splash Screen**: App initialization and auth state check
- **Login Screen**: Email/password authentication
- **Register Screen**: User registration with validation

### Main App
- **Home Screen**: Feed with public and following tabs
- **Post Detail**: Full post view with comments
- **Create Post**: Multi-media post creation
- **Profile**: User profile with stats and actions
- **Edit Profile**: Update profile information
- **Search**: Find and discover users

## 🔌 API Integration

### Retrofit API Service
The app uses Retrofit for type-safe HTTP requests:

```dart
// Example: Fetch posts
final posts = await apiService.getPosts(page, 15);

// Example: Like a post
await apiService.likePost(postId);

// Example: Create comment
await apiService.createComment(postId, {'body': 'Nice!'});
```

### Authentication
- Tokens are stored securely in Hive
- Auto-attached to requests via Dio interceptor
- Automatic logout on 401 errors

## 🏗️ State Management with Riverpod

The app uses Riverpod providers for state management:

```dart
// Watch a provider
final posts = ref.watch(postsProvider(1));

// Trigger an action
await ref.read(likePostProvider(postId));

// Invalidate cache
ref.invalidate(postsProvider);
```

## 💾 Local Storage

User authentication data is stored locally using Hive:
- Auth tokens
- User profile information
- Preferences

```dart
// Save token
StorageService.saveToken('token');

// Get token
final token = StorageService.getToken();

// Logout
StorageService.logout();
```

## 🔐 Security

- ✅ Password-based authentication
- ✅ Token-based API calls
- ✅ Secure local storage
- ✅ SSL/TLS for API communication
- ✅ Input validation on all forms
- ✅ Protected routes with auth checks

## 📲 Push Notifications

Firebase Cloud Messaging is configured:

```dart
// FCM token is automatically sent on login
await apiService.updateFcmToken({'fcm_token': token});

// Listen for messages
FirebaseMessaging.onMessage.listen((message) {
  // Handle foreground messages
});
```

## 🧪 Testing

### Unit Tests
```bash
flutter test test/unit_tests
```

### Integration Tests
```bash
flutter test integration_test
```

### Manual Testing
1. Login with test account
2. Navigate through different screens
3. Test CRUD operations
4. Verify offline behavior

## 📊 Performance

The app is optimized for performance:
- **Image Caching**: Cached Network Image for fast loading
- **Lazy Loading**: Pagination for posts and comments
- **State Preservation**: Riverpod caches provider states
- **Code Generation**: JSON serialization via build_runner

## 🐛 Debugging

### Enable Debug Logs
```dart
final dio = Dio();
dio.interceptors.add(LogInterceptor(
  responseBody: true,
  requestBody: true,
));
```

### Use DevTools
```bash
flutter pub global activate devtools
devtools
```

## 🚀 Building for Release

### Android
```bash
flutter build apk --release
# or AAB
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📝 Code Guidelines

- **File Organization**: Features-first structure
- **Naming**: CamelCase for classes, snake_case for files
- **Comments**: Explain the "why", not the "what"
- **Error Handling**: Always handle exceptions gracefully
- **Performance**: Use `const` constructors where possible

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/amazing-feature`
2. Commit changes: `git commit -m 'Add amazing feature'`
3. Push to branch: `git push origin feature/amazing-feature`
4. Open a Pull Request

## 📄 License

This project is proprietary and confidential.

## 🆘 Troubleshooting

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Conflicts
```bash
flutter pub upgrade
```

### Device Connection Issues
```bash
flutter doctor
flutter devices
```

## 📞 Support

For issues and questions, please contact the development team.

## 🎯 Future Enhancements

- [ ] Video recording and trimming
- [ ] Image filters and editing
- [ ] Direct messaging
- [ ] Stories feature
- [ ] Hashtags and mentions
- [ ] Advanced search with filters
- [ ] Push notification categories
- [ ] Offline mode improvements
- [ ] Dark mode improvements
- [ ] Accessibility features

---

**Version**: 1.0.0  
**Last Updated**: January 17, 2025
