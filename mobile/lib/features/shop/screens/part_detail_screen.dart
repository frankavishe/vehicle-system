import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../shared/models/spare_part_summary.dart';
import '../cart_controller.dart';

final _partDetailProvider = FutureProvider.autoDispose.family<SparePartSummary, String>((ref, id) {
  return ref.watch(autoserveApiProvider).getSparePart(id);
});

class PartDetailScreen extends ConsumerWidget {
  const PartDetailScreen({super.key, required this.partId});
  final String partId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final part = ref.watch(_partDetailProvider(partId));

    return Scaffold(
      appBar: AppBar(title: const Text('Part details')),
      body: part.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(_partDetailProvider(partId)),
            child: const Text('Could not load this part — tap to retry'),
          ),
        ),
        data: (p) => _PartDetailBody(part: p),
      ),
    );
  }
}

class _PartDetailBody extends ConsumerStatefulWidget {
  const _PartDetailBody({required this.part});
  final SparePartSummary part;

  @override
  ConsumerState<_PartDetailBody> createState() => _PartDetailBodyState();
}

class _PartDetailBodyState extends ConsumerState<_PartDetailBody> {
  int _quantity = 1;
  bool _adding = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    try {
      await ref.read(cartControllerProvider.notifier).add(
            sparePartId: widget.part.id,
            quantity: _quantity,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.part.title} added to cart')),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.part;
    final outOfStock = p.stockQuantity <= 0;
    final compatibility = [
      if (p.compatibleMake != null) p.compatibleMake,
      if (p.compatibleModel != null) p.compatibleModel,
    ].join(' ');
    final years = p.yearStart != null || p.yearEnd != null
        ? '${p.yearStart ?? 'Any'}–${p.yearEnd ?? 'Any'}'
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Icon(Icons.build_circle_outlined,
              size: 96, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 16),
        Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
        Text('SKU ${p.sku}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('TZS ${p.price}', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          outOfStock ? 'Out of stock' : '${p.stockQuantity} in stock',
          style: TextStyle(color: outOfStock ? Theme.of(context).colorScheme.error : Colors.green),
        ),
        if (p.vendor != null) ...[
          const SizedBox(height: 16),
          Text('Sold by', style: Theme.of(context).textTheme.labelLarge),
          Text(p.vendor!.name),
        ],
        if (compatibility.isNotEmpty || years != null) ...[
          const SizedBox(height: 16),
          Text('Compatibility', style: Theme.of(context).textTheme.labelLarge),
          Text([if (compatibility.isNotEmpty) compatibility, ?years].join(' · ')),
        ],
        if (p.description != null && p.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.labelLarge),
          Text(p.description!),
        ],
        const SizedBox(height: 24),
        if (!outOfStock) ...[
          Row(
            children: [
              const Text('Quantity'),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Text('$_quantity'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _quantity < p.stockQuantity ? () => setState(() => _quantity++) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _adding ? null : _addToCart,
            icon: _adding
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_shopping_cart),
            label: const Text('Add to cart'),
          ),
        ],
      ],
    );
  }
}
