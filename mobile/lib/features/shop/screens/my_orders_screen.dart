import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/order_dto.dart';

final myOrdersProvider = FutureProvider.autoDispose<List<OrderDto>>((ref) {
  return ref.watch(autoserveApiProvider).listOrders();
});

/// Mirrors ServiceStatus's `.name` -> wire-value mapping in
/// service_request.dart, but OrderStatus's @JsonValue strings already
/// equal `status.name.toUpperCase()` for every member (PENDING/PAID/
/// DISPATCHED/DELIVERED/CANCELLED all read the same forwards), so no
/// separate lookup table is needed here.
String orderStatusWireValue(OrderStatus status) => status.name.toUpperCase();

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myOrdersProvider),
        child: orders.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(myOrdersProvider),
              child: const Text('Could not load orders — tap to retry'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No orders yet — items you buy from the shop appear here.')),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final o = items[i];
                final itemCount = o.items.fold<int>(0, (sum, it) => sum + it.quantity);
                return ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text('Order #${o.id.substring(0, 8)}'),
                  subtitle: Text('$itemCount item${itemCount == 1 ? '' : 's'} · TZS ${o.totalAmount}'),
                  trailing: Chip(
                    label: Text(o.status.name),
                    backgroundColor: statusColor(orderStatusWireValue(o.status)).withValues(alpha: 0.15),
                  ),
                  onTap: () => context.push('/customer/orders/${o.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
