# 🧪 Role System Testing Guide

**Status**: Ready for Testing  
**Date**: January 17, 2026

---

## 🚀 Quick Start Testing

### Prerequisites
- Backend running: `php artisan serve --host=0.0.0.0 --port=8000`
- Flutter app ready: `flutter pub get && flutter pub run build_runner build`

---

## 📱 Test Scenarios

### Test 1: Normal User Registration & Login

**Objective**: Verify normal user registers with default role and cannot see post creation UI

**Steps**:
```
1. Open Flutter app
2. Tap "Sign In" link → Register screen
3. Fill form:
   - Name: "John User"
   - Email: "john@example.com"
   - Password: "password123"
   - Confirm: "password123"
   (No role selection - just registers)
4. Tap "Sign Up"
```

**Expected Results**:
```
✅ Registration succeeds
✅ Redirects to Home screen
✅ NO floating action button (FAB) visible
✅ Feed shows posts (if any)
✅ Can scroll, view posts, like/comment
```

**What's Happening**:
- Register method sends: `role: 'follower'` (default)
- Backend creates user with `is_admin = 0`
- User marked as normal user
- HomeScreen checks `isAdmin == false` → hides FAB

---

### Test 2: Normal User Cannot Access Create Post

**Objective**: Verify normal user cannot create posts even if they try to access the route directly

**Steps**:
```
1. Logged in as normal user (from Test 1)
2. Try one of these:
   a) Open URL bar and navigate to /create-post (if supported)
   b) Try to find any create button
3. Look for Post Creation UI
```

**Expected Results**:
```
✅ No FAB button visible
✅ Cannot find create post button anywhere
✅ If somehow reaches /create-post:
   ✅ Router redirects to /home
   OR
   ✅ Screen shows error "Only admins can create posts"
   ✅ Automatically redirects to /home
```

**What's Happening**:
- Layer 1: FAB conditional → null (not rendered)
- Layer 2: Router guard → checks isAdmin → redirects
- Layer 3: Screen init → verifies admin → redirects
- Result: Cannot access post creation

---

### Test 3: Admin User Registration (Manual)

**Objective**: Create admin user in database and verify they see post creation UI

**Steps** (Database Access):
```bash
# Option 1: Direct Database
mysql -u root -p project_mla
UPDATE users SET is_admin = 1 WHERE email = 'admin@example.com';

# Option 2: Laravel Tinker
php artisan tinker
>>> User::create(['name' => 'Admin', 'email' => 'admin@example.com', 'password' => Hash::make('admin123'), 'is_admin' => 1, 'role' => 'admin'])

# Option 3: Backend API (if you implement auth for this)
POST /api/admin/users
{
  "name": "Admin User",
  "email": "admin@example.com",
  "password": "admin123",
  "role": "admin"
}
```

**In Flutter App**:
```
1. Login with admin credentials:
   - Email: admin@example.com
   - Password: admin123
2. Home screen loads
```

**Expected Results**:
```
✅ Login succeeds
✅ Home screen shows floating action button (+)
✅ FAB is visible and clickable
✅ Icon is clear (add/plus icon)
```

**What's Happening**:
- User logged in with `is_admin = 1`
- AuthProvider stores `User.isAdmin = true`
- HomeScreen checks `isAdmin ?? false` → true
- FAB renders normally

---

### Test 4: Admin User Creates Post

**Objective**: Verify admin can successfully create a post

**Steps**:
```
1. Logged in as admin user (from Test 3)
2. Home screen visible with FAB (+)
3. Tap the FAB button
4. Create Post screen appears
5. Fill form:
   - Caption: "Hello, this is my first post!"
   - Media: Skip for now (optional)
6. Tap "Post" button
```

**Expected Results**:
```
✅ Create Post screen opens
✅ Form fields visible
✅ Caption field accepts text
✅ Post button enabled
✅ No error message about admin access
✅ On submit:
   ✅ Loading indicator shows
   ✅ After success: "Post created successfully" message
   ✅ Redirects back to Home
✅ Can see new post in feed
```

**What's Happening**:
- FAB visible → isAdmin = true
- Router allows access → isAdmin = true
- Screen loads → admin check passes
- Post created via API
- Backend validates → isAdmin = true → creates post
- Post appears in feed for all users

---

### Test 5: Normal User Interacts with Admin's Post

**Objective**: Verify normal users can like, comment, and share (but not edit/delete)

**Steps**:
```
1. Login as normal user
2. Home screen shows posts (from admin)
3. Find admin's post
4. Interact:
   a) Tap like icon → like post
   b) Tap comment icon → add comment
   c) Tap share icon → share post
5. Try to edit/delete post (should not be possible)
```

**Expected Results**:
```
✅ Can see all posts in feed
✅ Like button works → heart icon fills
✅ Comment works → comment screen opens
✅ Share works → share options appear
✅ No delete/edit buttons visible on posts
✅ If somehow tries to edit:
   ✅ Backend returns 403 Forbidden
   ✅ Cannot modify post
```

**What's Happening**:
- Normal users can read all posts
- Can interact (like, comment, share)
- Cannot post/edit/delete
- Backend enforces restrictions

---

### Test 6: Two Admin Users

**Objective**: Verify multiple admins can each create posts

**Steps**:
```
1. Create second admin in database:
   UPDATE users SET is_admin = 1 WHERE email = 'admin2@example.com';

2. Login as Admin 1 → Create post
3. Logout
4. Login as Admin 2 → Create post
5. Login as Normal User → View both posts
```

**Expected Results**:
```
✅ Both admins see FAB
✅ Both can create posts
✅ Both posts appear in feed
✅ Normal user sees both posts
✅ Can like/comment on both
```

**What's Happening**:
- Multiple users can have admin role
- Each admin has independent post management
- System supports multiple admins

---

### Test 7: Login/Logout Cycle

**Objective**: Verify role persists across login/logout

**Steps**:
```
1. Login as admin
2. See FAB
3. Logout
4. Login as admin again
5. Check FAB status
6. Logout
7. Login as normal user
8. Check no FAB
9. Logout
10. Login as normal user again
11. Check still no FAB
```

**Expected Results**:
```
✅ After admin login: FAB visible
✅ After logout and re-login: FAB visible
✅ After normal user login: No FAB
✅ After logout and re-login: Still no FAB
✅ Role consistent across sessions
```

**What's Happening**:
- Role stored in local storage
- Role fetched on login
- Role persists in session
- Logout clears storage
- Fresh login fetches role from API

---

## 🔍 Debugging Tips

### If FAB Shows for All Users
```
Debug Steps:
1. Check auth state in console
2. Print authState.user?.isAdmin
3. Verify backend returned correct is_admin field
4. Check Home screen FAB conditional:
   
   floatingActionButton: ref.watch(authStateProvider).user?.isAdmin ?? false
       ? FloatingActionButton(...)
       : null,
   
   ^ Should be checking isAdmin correctly
```

### If Admin Can't Create Posts
```
Debug Steps:
1. Check Router redirect:
   - Is it allowing access?
   - Or redirecting to /home?

2. Check CreatePostScreen init:
   - Does admin verification pass?
   - Or showing error message?

3. Check API response:
   - Is backend returning 403?
   - Or 201 created?

4. Check Console Logs:
   - Any error messages?
   - Auth state correct?
```

### If Normal User Sees FAB
```
Debug Steps:
1. Verify Backend is_admin field:
   SELECT email, is_admin, role FROM users;
   
   Should show: is_admin = 0 or false

2. Verify API Response:
   Login → check JSON response
   Should have: "is_admin": false

3. Verify Flutter Model:
   Check User.fromJson() mapping
   @JsonKey(name: 'is_admin')
   final bool isAdmin;

4. Verify Home Screen:
   Check conditional: ?? false
   If null → defaults to false
```

---

## 📊 Expected Database State

### After Test 1 & 2 (Normal User)
```sql
SELECT id, email, role, is_admin FROM users;

+----+-------------------+----------+----------+
| id | email             | role     | is_admin |
+----+-------------------+----------+----------+
| 1  | john@example.com  | follower | 0        |
+----+-------------------+----------+----------+
```

### After Test 3 (Admin User)
```sql
+----+-------------------+----------+----------+
| id | email             | role     | is_admin |
+----+-------------------+----------+----------+
| 1  | john@example.com  | follower | 0        |
| 2  | admin@example.com | admin    | 1        |
+----+-------------------+----------+----------+
```

### After Test 4 (Post Created by Admin)
```sql
SELECT id, user_id, caption, created_at FROM posts;

+----+---------+----------------------------+---------------------+
| id | user_id | caption                    | created_at          |
+----+---------+----------------------------+---------------------+
| 1  | 2       | Hello, this is my first... | 2026-01-17 10:30:00 |
+----+---------+----------------------------+---------------------+
```

---

## ✅ Verification Checklist

- [ ] Normal user can register
- [ ] Normal user cannot see FAB
- [ ] Admin user can see FAB
- [ ] Admin user can create posts
- [ ] Normal user cannot create posts
- [ ] Normal user can see admin posts
- [ ] Normal user can like posts
- [ ] Normal user can comment
- [ ] Normal user can share
- [ ] Admin posts appear in feed
- [ ] Multiple admins supported
- [ ] Role persists after logout/login
- [ ] Backend validates admin status
- [ ] No 403 errors for normal operations

---

## 🔴 Common Issues & Solutions

### Issue 1: FAB shows for all users
**Solution**: Check `ref.watch(authStateProvider).user?.isAdmin ?? false` in HomeScreen
- Ensure it's not always true
- Verify backend returns correct is_admin

### Issue 2: Admin cannot create posts
**Solution**: Check router redirect path
- Verify /create-post route has guard
- Check screen init admin check
- Verify API returns correct user.isAdmin

### Issue 3: Normal user can access /create-post
**Solution**: Ensure three layers:
- Layer 1: FAB hidden (UI)
- Layer 2: Router redirects (Routing)
- Layer 3: Screen shows error (Screen)
- Layer 4: Backend returns 403 (API)

### Issue 4: Wrong user logged in
**Solution**: 
- Tap logout
- Close and reopen app
- Login again with correct credentials

### Issue 5: No FAB after admin login
**Solution**:
- Hot restart app (not just hot reload)
- Check database is_admin = 1
- Check API response includes is_admin field
- Verify JSON mapping: @JsonKey(name: 'is_admin')

---

## 📝 Test Report Template

```markdown
## Role System Test Report
Date: [Date]
Tester: [Name]

### Test 1: Normal User Registration
Status: PASS / FAIL
Notes: [Observations]

### Test 2: Normal User Cannot Post
Status: PASS / FAIL
Notes: [Observations]

### Test 3: Admin User Login
Status: PASS / FAIL
Notes: [Observations]

### Test 4: Admin User Creates Post
Status: PASS / FAIL
Notes: [Observations]

### Test 5: Normal User Interacts
Status: PASS / FAIL
Notes: [Observations]

### Overall Status
All Tests: PASS / FAIL
Issues Found: [List any]
Recommendations: [Any improvements]
```

---

## 🎓 Key Concepts

### Role Determination
- **Normal User**: `is_admin = 0 (false)`
- **Admin User**: `is_admin = 1 (true)`
- **Check**: `user?.isAdmin ?? false`

### Permission Checks (Layers)
1. **UI**: Don't show button
2. **Router**: Don't load route
3. **Screen**: Verify and error
4. **API**: Validate and reject

### Normal User Can
- ✅ Register
- ✅ Login
- ✅ View posts
- ✅ Like posts
- ✅ Comment on posts
- ✅ Share posts
- ✅ Follow users
- ✅ Search

### Normal User Cannot
- ❌ Create posts
- ❌ Edit posts
- ❌ Delete posts
- ❌ Access /create-post

### Admin User Can (Everything above +)
- ✅ Create posts
- ✅ Edit own posts
- ✅ Delete own posts
- ✅ Access /create-post
- ✅ See FAB button

---

## 🚀 Ready to Test!

The role system is fully implemented:

✅ Registration with default normal user role  
✅ Home screen FAB only for admins  
✅ Router guard on post creation  
✅ Screen-level verification  
✅ Backend validation  

**Start with Test 1 and work through all 7!**

