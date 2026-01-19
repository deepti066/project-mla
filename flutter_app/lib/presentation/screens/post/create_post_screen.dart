import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/post_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late TextEditingController _captionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
    
    // Verify admin access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      if (authState.user?.isAdmin != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only admins can create posts')),
        );
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleCreatePost() async {
    if (_captionController.text.isEmpty) {
      _showSnackBar('Please write a caption');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual post creation with media upload
      // For now, just show success message
      _showSnackBar('Post created successfully');
      context.go('/home');
    } catch (e) {
      _showSnackBar('Error creating post: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleCreatePost,
            child: const Text('Post'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caption TextField
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your caption...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Media Upload Section
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Tap to add images or videos'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement image picker
                        _showSnackBar('Image picker coming soon');
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Media'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
