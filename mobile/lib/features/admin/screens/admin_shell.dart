import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold_shell.dart';
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
    const tabs = [DisputeListScreen(), OversightScreen(), ModerationScreen(), ProfileScreen()];

    return AppScaffoldShell(
      title: 'Admin · ${_titles[index]}',
      selectedIndex: index,
      onDestinationSelected: (i) => ref.read(shellTabIndexProvider.notifier).state = i,
      tabs: tabs,
      destinations: const [
        AppNavDestination(
          icon: Icons.report_problem_outlined,
          selectedIcon: Icons.report_problem,
          label: 'Disputes',
        ),
        AppNavDestination(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Oversight'),
        AppNavDestination(icon: Icons.shield_outlined, selectedIcon: Icons.shield, label: 'Moderation'),
        AppNavDestination(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
      ],
    );
  }
}
