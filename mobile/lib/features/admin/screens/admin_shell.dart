import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/screens/profile_screen.dart';
import '../../shell/shell_tab_index.dart';
import 'dispute_list_screen.dart';
import 'moderation_screen.dart';
import 'oversight_screen.dart';

/// Admin's bottom-nav shell — one tab per prioritized user story (P1
/// Disputes, P2 Oversight, P3 Moderation) plus the Profile tab every
/// other shell already has. Notifications is reached via a bell icon on
/// Oversight rather than its own tab (research.md §2 — a flagged
/// simplification, not a hard requirement).
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key});

  static const _titles = ['Disputes', 'Oversight', 'Moderation', 'Profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellTabIndexProvider);
    const tabs = [
      DisputeListScreen(),
      OversightScreen(),
      ModerationScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Admin · ${_titles[index]}')),
      body: IndexedStack(index: index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(shellTabIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.report_problem_outlined), label: 'Disputes'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Oversight'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Moderation'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
