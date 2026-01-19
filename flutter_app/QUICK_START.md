# 🚀 Flutter App - Quick Start Guide

Get your Flutter app up and running in 30 minutes!

## ⏱️ Quick Setup (30 minutes)

### 1️⃣ Prerequisites (5 minutes)
Ensure you have:
- ✅ Flutter 3.13+ installed
- ✅ Xcode/Android Studio installed
- ✅ Project files downloaded
- ✅ Backend API running on your machine

### 2️⃣ Dependencies (5 minutes)

```bash
cd /Users/saranga/vs\ code\ projects/project-mla/flutter_app

# Get all dependencies
flutter pub get

# Generate code
flutter pub run build_runner build
```

### 3️⃣ Configuration (5 minutes)

Edit `lib/config/api_config.dart`:

```dart
// Replace with your machine IP
static const String _baseUrl = 'http://192.168.1.100:8000';
```

Get your IP:
```bash
ipconfig getifaddr en0
```

### 4️⃣ Start Backend (5 minutes)

```bash
cd /Users/saranga/vs\ code\ projects/project-mla

# Start server
php artisan serve --host=0.0.0.0 --port=8000
```

Keep this terminal running!

### 5️⃣ Run App (5 minutes)

```bash
# For iOS
open -a Simulator
flutter run -d iOS

# For Android
# Start emulator first, then:
flutter run
```

✅ **App should launch!**

## 🧪 Quick Tests (10 minutes)

### Test 1: Authentication
1. Click "Sign Up"
2. Enter details:
   - Name: `Test User`
   - Email: `test@example.com`
   - Password: `password123`
3. Click "Sign Up"
4. Should redirect to home screen

### Test 2: Feed
1. You should see home screen
2. Check if any posts appear
3. Scroll down to load more

### Test 3: Navigation
1. Click bottom navigation
2. Try different screens
3. Check if data loads

## 🛠️ Troubleshooting Quick Fixes

### "Build failed: Plugin not found"
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### "Connection refused"
- Check backend is running: `http://192.168.1.100:8000`
- Verify correct IP in `api_config.dart`
- Check firewall isn't blocking

### "Device not found"
```bash
flutter devices
flutter emulators
flutter emulators --launch <name>
```

### "Model generation failed"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📚 What's Where?

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/config/api_config.dart` | API configuration |
| `lib/data/providers/auth_provider.dart` | Authentication logic |
| `lib/presentation/screens/auth/login_screen.dart` | Login UI |
| `lib/presentation/screens/home/home_screen.dart` | Main feed |

## 📱 Key Features to Test

- [ ] Login/Register
- [ ] View feed
- [ ] Like posts
- [ ] Add comments
- [ ] Search users
- [ ] View profile
- [ ] Follow users

## 🎯 Next Steps

1. **Customize colors** - Edit `lib/config/theme/app_theme.dart`
2. **Add your logo** - Replace assets
3. **Implement missing screens** - Post creation, comments
4. **Test all features** - Complete user journey
5. **Build APK/IPA** - Release build

## 💡 Pro Tips

### Hot Reload While Development
```bash
# Terminal: Press 'r' to reload
# Press 'R' to restart app
# Preserves app state (mostly)
```

### Debug Logging
```bash
flutter logs
```

### Check Network Calls
Add to `main.dart`:
```dart
dio.interceptors.add(LogInterceptor(
  responseBody: true,
  requestBody: true,
));
```

## 🚀 Common Workflow

```bash
# Terminal 1: Backend
cd project-mla
php artisan serve --host=0.0.0.0

# Terminal 2: App watcher
cd flutter_app
flutter pub run build_runner watch

# Terminal 3: Flutter app
flutter run

# In app development:
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

## 📊 Project Structure

```
flutter_app/
├── lib/
│   ├── config/         ← API URL, routes, theme
│   ├── data/           ← Models, providers, services
│   └── presentation/   ← Screens & widgets
├── pubspec.yaml        ← Dependencies
├── SETUP_GUIDE.md      ← Detailed setup
└── INTEGRATION_GUIDE.md ← Backend connection
```

## 🔗 Important Files

**To change API endpoint:**
```
lib/config/api_config.dart (line 6)
```

**To add new screen:**
```
lib/presentation/screens/your_screen.dart
```

**To add new provider:**
```
lib/data/providers/your_provider.dart
```

## ✅ Quick Checklist

- [ ] Flutter installed (`flutter --version`)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Code generated (`flutter pub run build_runner build`)
- [ ] Backend running (port 8000)
- [ ] API URL configured (with correct IP)
- [ ] App starts (`flutter run`)
- [ ] Can login/register
- [ ] Feed displays posts

## 📞 Quick Help

**Can't connect to API?**
```bash
# Check backend IP
ifconfig | grep "inet " | grep -v "127.0.0.1"

# Test API manually
curl http://192.168.1.100:8000/api/posts
```

**Need to restart everything?**
```bash
# Clean everything
flutter clean
rm -rf pubspec.lock
flutter pub get

# Rebuild
flutter pub run build_runner build
flutter run
```

**Want fresh database?**
```bash
# In backend directory
php artisan migrate:refresh --seed
```

## 🎓 Learn More

- **Full Setup**: See `SETUP_GUIDE.md`
- **Integration Details**: See `INTEGRATION_GUIDE.md`
- **Project README**: See `README.md`
- **Backend Docs**: See parent directory `FLUTTER_INTEGRATION.md`

## 🎬 Video Guide (Recommended)

1. Watch Flutter official intro (15 min)
2. Watch Riverpod state management (20 min)
3. Understand HTTP requests with Dio (10 min)
4. Explore this codebase (15 min)

## ✨ You're Ready!

Your Flutter app is configured and ready to go. Follow the quick tests above, and you should have a working social media app connected to your backend in under an hour!

**Happy coding!** 🎉

---

**Next**: Start with `SETUP_GUIDE.md` for detailed instructions  
**Questions?**: Check `INTEGRATION_GUIDE.md` for backend integration help
