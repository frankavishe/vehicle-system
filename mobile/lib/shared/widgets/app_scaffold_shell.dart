import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Simple (icon, label) pair for one bottom-nav destination — role-agnostic
/// so all three role shells (customer/provider/admin) can share the
/// Scaffold/NavigationBar skeleton below while keeping their own
/// role-specific tab lists.
class AppNavDestination {
  const AppNavDestination({required this.icon, this.selectedIcon, required this.label});

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// Centralizes the Scaffold(AppBar + IndexedStack + NavigationBar)
/// skeleton previously duplicated across customer_shell.dart,
/// provider_shell.dart and admin_shell.dart. Also draws a 1px top border
/// on the nav bar (to match web/'s `border-t` chrome) since
/// NavigationBarThemeData has no native field for that.
class AppScaffoldShell extends StatelessWidget {
  const AppScaffoldShell({
    super.key,
    required this.title,
    this.actions,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.tabs,
    required this.destinations,
  });

  final String title;
  final List<Widget>? actions;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> tabs;
  final List<AppNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: IndexedStack(index: selectedIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: semantic.line)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: d.selectedIcon != null ? Icon(d.selectedIcon) : null,
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }
}
