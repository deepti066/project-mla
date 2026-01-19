import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Center(
        child: Text('Post #$postId'),
      ),
    );
  }
}
