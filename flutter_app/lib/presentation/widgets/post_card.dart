import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/post_model.dart';
import '../../data/providers/post_provider.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => context.go('/profile/${post.user.id}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: post.user.avatar != null
                        ? CachedNetworkImageProvider(post.user.avatar!)
                        : null,
                    child: post.user.avatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/profile/${post.user.id}'),
                            child: Text(
                              post.user.name ?? 'Guest',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (post.user.isVerified ?? false)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // More Menu
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('Report'),
                    ),
                    const PopupMenuItem(
                      child: Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.caption,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          // Media
          if (post.media.isNotEmpty)
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: post.media.length,
                itemBuilder: (context, index) {
                  final media = post.media[index];
                  return CachedNetworkImage(
                    imageUrl: media.mediaUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          // Engagement Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${post.likesCount} likes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${post.commentsCount} comments',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${post.sharesCount} shares',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: post.isLikedByAuth ? Icons.favorite : Icons.favorite_outline,
                    color: post.isLikedByAuth ? Colors.red : Colors.grey,
                    label: 'Like',
                    onTap: () {
                      if (post.isLikedByAuth) {
                        ref.read(unlikePostProvider(post.id));
                      } else {
                        ref.read(likePostProvider(post.id));
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                    onTap: () => context.go('/post/${post.id}'),
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () => ref.read(sharePostProvider((post.id, null))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color ?? Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color ?? Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
