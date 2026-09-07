import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold_shell.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../shell/shell_tab_index.dart';
import 'documents_screen.dart';
import 'job_list_screen.dart';

/// Shared shell for MECHANIC and RECOVERY — both roles get the same tab
/// set (job list, documents, notifications, profile); only the job-list
/// query and the mechanic-only parts-sourcing section (job detail screen)
/// differ per role.
class ProviderShell extends ConsumerWidget {
  const ProviderShell({super.key, required this.role});
  final String role; // MECHANIC | RECOVERY

  static const _titles = ['Jobs', 'Documents', 'Notifications', 'Profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellTabIndexProvider);
    final tabs = [
      JobListScreen(role: role),
      const DocumentsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return AppScaffoldShell(
      title: '${role == 'MECHANIC' ? 'Mechanic' : 'Recovery'} · ${_titles[index]}',
      selectedIndex: index,
      onDestinationSelected: (i) => ref.read(shellTabIndexProvider.notifier).state = i,
      tabs: tabs,
      destinations: const [
        AppNavDestination(icon: Icons.work_outline, selectedIcon: Icons.work, label: 'Jobs'),
        AppNavDestination(icon: Icons.description_outlined, selectedIcon: Icons.description, label: 'Docs'),
        AppNavDestination(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          label: 'Alerts',
        ),
        AppNavDestination(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
      ],
    );
  }
}
