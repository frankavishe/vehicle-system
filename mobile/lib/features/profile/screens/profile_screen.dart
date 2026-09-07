import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';

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
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            user == null || user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
            style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(user?.email ?? ''),
        const SizedBox(height: 8),
        AppBadge(label: user?.role ?? '', tone: AppTone.neutral),
        const SizedBox(height: 32),
        AppButton(
          label: 'Log out',
          variant: AppButtonVariant.secondary,
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          expand: true,
        ),
      ],
    );
  }
}
