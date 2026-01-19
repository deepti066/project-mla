import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/user_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchUsersProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
      ),
      body: _searchQuery.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Search for users',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : searchResults.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatar != null
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: user.avatar == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () => context.go('/profile/${user.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
            ),
    );
  }
}
