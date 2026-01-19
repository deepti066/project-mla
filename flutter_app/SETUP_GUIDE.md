# Flutter Development Setup Guide

## 📋 Complete Setup Instructions

### Phase 1: Environment Setup (30 minutes)

#### 1.1 Install Flutter SDK
```bash
# macOS with Homebrew
brew install flutter

# Or download from flutter.dev
# Set PATH in ~/.zshrc or ~/.bash_profile
export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"
```

#### 1.2 Verify Installation
```bash
flutter --version
flutter doctor
```

#### 1.3 Install Xcode (for iOS development)
```bash
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app/xcode-select
```

#### 1.4 Install Android Studio
- Download from android.com
- Configure Android SDK
- Set `ANDROID_HOME` environment variable

### Phase 2: Project Setup (20 minutes)

#### 2.1 Navigate to Project
```bash
cd /Users/saranga/vs\ code\ projects/project-mla/flutter_app
```

#### 2.2 Get Dependencies
```bash
flutter pub get
```

#### 2.3 Generate Code
```bash
# Install build_runner and code generator
flutter pub get

# Generate serialization code
flutter pub run build_runner build

# Or watch for changes
flutter pub run build_runner watch
```

#### 2.4 Firebase Setup
1. Go to Firebase Console
2. Create new project
3. Add iOS app:
   - Bundle ID: `com.example.socialMediaApp`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/`

4. Add Android app:
   - Package: `com.example.social_media_app`
   - Download `google-services.json`
   - Place in `android/app/`

### Phase 3: Configure API Endpoints (10 minutes)

#### 3.1 Update API Config
Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Change this to your backend URL
  static const String _baseUrl = 'http://192.168.1.100:8000'; // Your machine IP
  // or for production
  // static const String _baseUrl = 'https://api.yourdomain.com';
  
  static String get baseUrl => _baseUrl;
  static String get apiBaseUrl => '$_baseUrl/api';
  // ...
}
```

**For Local Development:**
- Use your machine's IP address: `ipconfig getifaddr en0`
- Example: `http://192.168.1.100:8000`

**For Production:**
- Use your domain: `https://api.yourdomain.com`

#### 3.2 Update Firebase Options
Edit `lib/firebase_options.dart` with your Firebase credentials from Firebase Console.

### Phase 4: Run the App (5 minutes)

#### 4.1 Check Connected Devices
```bash
flutter devices
```

#### 4.2 Run on iOS Simulator
```bash
# Start simulator
open -a Simulator

# Run app
flutter run -d iOS
```

#### 4.3 Run on Android Emulator
```bash
# List Android devices/emulators
flutter emulators

# Start emulator
flutter emulators --launch <emulator_name>

# Run app
flutter run
```

#### 4.4 Run on Physical Device
```bash
# Connect device and enable USB Debugging
flutter run

# For iOS: Trust certificate on device
```

### Phase 5: Development Workflow

#### 5.1 Hot Reload
- Saves changes in 1 second
- Preserves app state
- Press 'r' in terminal

#### 5.2 Hot Restart
- Full app restart
- Loses app state
- Press 'R' in terminal

#### 5.3 Build Runner Watch
```bash
# In separate terminal
flutter pub run build_runner watch
```

#### 5.4 Debug Console
```bash
# View logs
flutter logs

# With specific tag
flutter logs -c 'TAG'
```

### Phase 6: Testing API Integration

#### 6.1 Test Login
1. Open app
2. Go to Register screen
3. Create test account:
   - Name: Test User
   - Email: test@example.com
   - Password: Password123!

4. Login with those credentials

#### 6.2 Test Post Feed
1. Login successfully
2. Check if posts load
3. Try liking a post
4. Check home button navigation

#### 6.3 Test Profile
1. Navigate to Profile
2. Check if user data loads
3. Try following a user
4. Check follower list

## 🔧 Common Issues & Solutions

### Issue: Build fails with "Plugin not found"
**Solution:**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: iOS build fails
**Solution:**
```bash
cd ios
pod repo update
cd ..
flutter pub get
flutter run
```

### Issue: Android build fails
**Solution:**
```bash
./gradlew clean
flutter clean
flutter pub get
flutter run
```

### Issue: Firebase initialization fails
**Solution:**
1. Check Firebase credentials in config file
2. Ensure json files are in correct locations
3. Rebuild app: `flutter clean && flutter run`

### Issue: API calls return 401 Unauthorized
**Solution:**
1. Check if login is successful
2. Verify token is being saved
3. Check API base URL configuration
4. Ensure backend server is running

### Issue: Images not loading
**Solution:**
1. Check image URLs are valid
2. Ensure network permission in android/iOS
3. Check firewall/network connectivity

## 📚 Code Generation

### Generate Models
The app uses `json_serializable` for automatic JSON serialization:

```bash
flutter pub run build_runner build
```

This generates:
- `user_model.g.dart`
- `post_model.g.dart`
- `comment_model.g.dart`
- `api_service.g.dart`

### Watch for Changes
```bash
flutter pub run build_runner watch
```

## 🐛 Debugging Tips

### 1. DevTools
```bash
flutter pub global activate devtools
devtools

# In another terminal
flutter run --observe
# Copy the observe URL into DevTools
```

### 2. Print Debugging
```dart
print('Debug: $variable');
debugPrint('Debug: $variable'); // For production
```

### 3. Network Monitoring
Add logging interceptor in Dio:
```dart
dio.interceptors.add(LogInterceptor(
  responseBody: true,
  requestBody: true,
));
```

### 4. Riverpod DevTools
```bash
flutter pub add riverpod_generator
# Add to main.dart observer
ProviderContainer(
  overrides: [],
  observers: [RiverpodObserver()],
)
```

## 📦 Dependency Management

### Add New Package
```bash
flutter pub add package_name
```

### Upgrade Packages
```bash
flutter pub upgrade
```

### Clean Upgrade
```bash
flutter clean
flutter pub get
```

## 🚀 Performance Tips

1. **Use const constructors** - Reduces rebuilds
2. **Lazy loading** - Load data as needed
3. **Image caching** - Use CachedNetworkImage
4. **Code splitting** - Separate concerns into modules
5. **Riverpod caching** - Leverage provider caching

## 📱 Device Testing

### Test Different Screensizes
```bash
# List available devices
flutter emulators

# Run on different device
flutter run -d <device_id>
```

### Test Different Android Versions
```bash
# Create emulator with Android 13
avdmanager create avd -n Android13 -k "system-images;android-13;google_apis;x86"
```

## 🔐 Security Checklist

- [ ] Change API base URL to your backend
- [ ] Update Firebase credentials
- [ ] Remove debug logging in production
- [ ] Enable SSL pinning for HTTPS
- [ ] Use secure storage for tokens
- [ ] Implement request signing
- [ ] Add rate limiting
- [ ] Validate all user inputs

## 📝 Project Structure Best Practices

```
lib/
├── config/          # App configuration (theme, routes, constants)
├── data/            # Data layer (models, services, providers)
├── presentation/    # UI layer (screens, widgets)
└── main.dart        # Entry point
```

### Feature-Based Structure (Alternative)
```
lib/
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── providers/
│   │   └── models/
│   ├── posts/
│   └── profile/
└── config/
```

## 🎯 Next Steps

1. **Run the app** - Ensure everything compiles
2. **Test authentication** - Register and login
3. **Explore features** - Test all main screens
4. **Customize UI** - Adjust colors, fonts, layouts
5. **Implement missing screens** - Post creation, comments
6. **Add real data** - Connect to your backend
7. **Optimize performance** - Profile and optimize
8. **Deploy to stores** - Build and publish

## 📞 Getting Help

### Useful Resources
- Flutter Docs: https://flutter.dev/docs
- Riverpod Docs: https://riverpod.dev
- Dio HTTP: https://pub.dev/packages/dio
- Firebase: https://firebase.google.com/docs/flutter/setup

### Community
- Stack Overflow: Tag with `flutter`
- GitHub Issues: flutter/flutter
- Reddit: r/FlutterDev

## 🎓 Learning Path

1. **Basics** (Week 1)
   - Understand Flutter structure
   - Learn about widgets and state
   - Practice with simple screens

2. **State Management** (Week 2)
   - Learn Riverpod concepts
   - Implement providers
   - Handle async operations

3. **API Integration** (Week 3)
   - Setup Dio and Retrofit
   - Implement API calls
   - Handle errors and loading states

4. **Advanced** (Week 4)
   - Firebase integration
   - Push notifications
   - Advanced UI patterns

## 🚀 Deployment Checklist

### Before Release
- [ ] All screens implemented
- [ ] API integration complete
- [ ] Error handling added
- [ ] Performance optimized
- [ ] Security hardened
- [ ] Testing completed
- [ ] App signed
- [ ] Screenshots prepared
- [ ] Store listings created
- [ ] Version bumped

### Android Release
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS Release
```bash
flutter build ios --release
```

---

**Version**: 1.0  
**Last Updated**: January 17, 2025
