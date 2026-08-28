import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../shell/shell_tab_index.dart';
import '../../shop/cart_controller.dart';
import '../../shop/screens/shop_screen.dart';
import 'my_requests_screen.dart';
import 'request_service_screen.dart';

class CustomerShell extends ConsumerWidget {
  const CustomerShell({super.key});

  // Appended after the existing four (not prepended) so this stays index
  // 4 — main.dart's FCM tap handler hardcodes index 2 for Notifications,
  // shared via shellTabIndexProvider with ProviderShell's own tab order.
  static const _shopTabIndex = 4;

  static const _titles = ['Request Service', 'My Requests', 'Notifications', 'Profile', 'Shop'];
  static const _tabs = [
    RequestServiceScreen(),
    MyRequestsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
    ShopScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellTabIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[index]),
        actions: index == _shopTabIndex ? const [_OrdersAction(), _CartAction()] : null,
      ),
      body: IndexedStack(index: index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(shellTabIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add_road), label: 'Request'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Shop'),
        ],
      ),
    );
  }
}

class _OrdersAction extends StatelessWidget {
  const _OrdersAction();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.receipt_long_outlined),
      tooltip: 'My orders',
      onPressed: () => context.push('/customer/orders'),
    );
  }
}

class _CartAction extends ConsumerWidget {
  const _CartAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);
    return IconButton(
      icon: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
      tooltip: 'Cart',
      onPressed: () => context.push('/customer/cart'),
    );
  }
}
