import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/autoserve_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/order_dto.dart';
import '../../../shared/models/order_shipment_dto.dart';
import 'my_orders_screen.dart';

final _orderDetailProvider = FutureProvider.autoDispose.family<OrderDto, String>((ref, id) {
  return ref.watch(autoserveApiProvider).getOrder(id);
});

final _orderShipmentProvider =
    FutureProvider.autoDispose.family<OrderShipmentDto?, String>((ref, id) {
  return ref.watch(autoserveApiProvider).getOrderShipment(id);
});

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(_orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(_orderDetailProvider(orderId)),
            child: const Text('Could not load this order — tap to retry'),
          ),
        ),
        data: (o) => _OrderDetailBody(order: o),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  const _OrderDetailBody({required this.order});
  final OrderDto order;

  bool get _isCancellable => order.status == OrderStatus.pending;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    await ref.read(autoserveApiProvider).cancelOrder(order.id);
    ref.invalidate(_orderDetailProvider(order.id));
    ref.invalidate(myOrdersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipment =
        order.status == OrderStatus.dispatched || order.status == OrderStatus.delivered
            ? ref.watch(_orderShipmentProvider(order.id))
            : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('Order #${order.id.substring(0, 8)}', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Chip(
              label: Text(order.status.name),
              backgroundColor:
                  statusColor(orderStatusWireValue(order.status)).withValues(alpha: 0.15),
            ),
          ],
        ),
        if (order.deliveryAddress != null) ...[
          const SizedBox(height: 16),
          Text('Delivery address', style: Theme.of(context).textTheme.labelLarge),
          Text(order.deliveryAddress!),
        ],
        const SizedBox(height: 16),
        Text('Items', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        for (final item in order.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: Text('${item.sparePart.title} × ${item.quantity}')),
                Text('TZS ${item.unitPrice}'),
              ],
            ),
          ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: Theme.of(context).textTheme.titleMedium),
            Text('TZS ${order.totalAmount}', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        if (shipment != null) ...[
          const Divider(height: 40),
          Text('Shipment', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          shipment.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('Could not load shipment status.'),
            data: (s) => s == null
                ? const Text('Not dispatched yet.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.courierName != null) Text('Courier: ${s.courierName}'),
                      if (s.trackingRef != null) Text('Tracking ref: ${s.trackingRef}'),
                      if (s.deliveredAt != null)
                        Text('Delivered: ${s.deliveredAt}')
                      else if (s.dispatchedAt != null)
                        Text('Dispatched: ${s.dispatchedAt}'),
                    ],
                  ),
          ),
        ],
        if (_isCancellable) ...[
          const Divider(height: 40),
          // A PENDING order means checkout succeeded but no successful
          // payment has landed yet — either the customer hasn't paid, or
          // (CheckoutScreen's own payOrder() call failed, e.g. the gateway
          // rejected the request) they were routed here specifically to
          // retry it, since the cart that built this order is already
          // consumed and checkout() can't be replayed.
          _PayNowSection(orderId: order.id),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => _cancel(context, ref), child: const Text('Cancel order')),
        ],
      ],
    );
  }
}

class _PayNowSection extends ConsumerStatefulWidget {
  const _PayNowSection({required this.orderId});
  final String orderId;

  @override
  ConsumerState<_PayNowSection> createState() => _PayNowSectionState();
}

class _PayNowSectionState extends ConsumerState<_PayNowSection> {
  PaymentMethod _method = PaymentMethod.card;
  bool _submitting = false;
  String? _error;

  Future<void> _pay() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final checkoutUrl = await ref.read(autoserveApiProvider).payOrder(widget.orderId, _method);
      await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
    } on DioException catch (e) {
      setState(() => _error = extractApiErrorMessage(e, fallback: 'Could not start payment.'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment method', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final method in PaymentMethod.values)
              ChoiceChip(
                label: Text(method.label),
                selected: _method == method,
                onSelected: (_) => setState(() => _method = method),
              ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _submitting ? null : _pay,
          child: _submitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Pay now'),
        ),
      ],
    );
  }
}
