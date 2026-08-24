import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 32,
          child: Text(
            user == null || user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 16),
        Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(user?.email ?? ''),
        const SizedBox(height: 4),
        Chip(label: Text(user?.role ?? '')),
        const SizedBox(height: 32),
        FilledButton.tonal(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          child: const Text('Log out'),
        ),
      ],
    );
  }
}
