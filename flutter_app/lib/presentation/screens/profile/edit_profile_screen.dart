import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/http_provider.dart';
import '../../../data/services/api_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  File? _selectedImage;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();

    // Pre-fill with current user data
    final currentUser = ref.read(authStateProvider).user;
    if (currentUser != null) {
      _nameController.text = currentUser.name ?? '';
      _bioController.text = currentUser.bio ?? '';
    }

    // Optional: Refresh latest user data from server
    Future.microtask(() => _refreshUserData());
  }

  Future<void> _refreshUserData() async {
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getCurrentUser();
      final user = User.fromJson(data);

      if (mounted) {
        setState(() {
          _nameController.text = user.name ?? _nameController.text;
          _bioController.text = user.bio ?? _bioController.text;
        });
      }
    } catch (e) {
      debugPrint('Failed to refresh user data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Name cannot be empty');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final api = ref.read(apiServiceProvider);

      dio.MultipartFile? avatarFile;
      if (_selectedImage != null) {
        avatarFile = await dio.MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final response = await api.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        avatar: avatarFile,
        isPrivate: null, // add if you have a toggle
      );

      // Update local auth state
      final currentUser = ref.read(authStateProvider).user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          avatar: response['avatar'] as String? ?? currentUser.avatar,
        );
        ref.read(authStateProvider.notifier).updateUser(updatedUser);
      }

      if (!mounted) return;

      // Show success dialog – NO pop() here
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Profile Updated!',
        desc: 'Your changes have been saved successfully.',
        btnOkText: 'Done',
        btnOkOnPress: () {
          // Navigate back safely using go_router
          context.pop(); // This is safe here because it's called after dialog confirmation
        },
        btnOkColor: const Color(0xFF6366F1),
      ).show();

    } catch (e) {
      if (!mounted) return;
      _showError('Failed to update profile: ${e.toString().split('\n').first}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Error',
      desc: message,
      btnOkText: 'OK',
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Avatar with edit overlay
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : (currentUser?.avatar != null
                        ? NetworkImage(currentUser!.avatar!) as ImageProvider
                        : null),
                    child: (_selectedImage == null && currentUser?.avatar == null)
                        ? const Icon(Icons.person, size: 70, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Your full name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 24),

            // Bio
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell something about yourself...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
