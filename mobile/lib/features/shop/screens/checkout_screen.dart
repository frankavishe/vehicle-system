import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/autoserve_api.dart';
import '../../../shared/models/order_dto.dart';
import '../cart_controller.dart';
import 'my_orders_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _address = TextEditingController();
  PaymentMethod _method = PaymentMethod.card;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_address.text.trim().isEmpty) {
      setState(() => _error = 'Enter a delivery address.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final api = ref.read(autoserveApiProvider);

    final OrderDto order;
    try {
      order = await api.checkout(deliveryAddress: _address.text.trim());
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = extractApiErrorMessage(e, fallback: 'Could not place order.');
          _submitting = false;
        });
      }
      return;
    }

    // The order now exists and the cart it was built from is already
    // consumed server-side — from here on a failure (e.g. the payment
    // gateway itself rejecting the request) must not strand the customer
    // back on this form, since retrying checkout() would just fail again
    // with "Cart is empty." Refresh eagerly and route to My Orders either
    // way; OrderDetailScreen offers its own "Pay now" retry for exactly
    // this case.
    await ref.read(cartControllerProvider.notifier).refresh();
    ref.invalidate(myOrdersProvider);

    try {
      final checkoutUrl = await api.payOrder(order.id, _method);
      // Hands off to the gateway's hosted checkout page instead of a
      // native payment UI — same pattern as the parts-sourcing "Buy now"
      // flow in request_detail_screen.dart.
      await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete payment in your browser, then check My Orders.')),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Order placed, but payment could not start '
            '(${extractApiErrorMessage(e, fallback: 'unknown error')}). '
            'Retry payment from the order.',
          ),
        ));
      }
    }
    if (mounted) context.go('/customer/orders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _address,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
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
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _placeOrder,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Place order & pay'),
          ),
        ],
      ),
    );
  }
}
