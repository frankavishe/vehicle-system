import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text('${role == 'MECHANIC' ? 'Mechanic' : 'Recovery'} · ${_titles[index]}')),
      body: IndexedStack(index: index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(shellTabIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.description), label: 'Docs'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
