import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../shared/models/spare_part_summary.dart';
import '../cart_controller.dart';

/// Server-side filters GET /parts actually supports (apps/catalog/filters.py
/// only has make/model/category/year — no free-text param); `query` is
/// applied client-side on top of these, same simplification flagged on
/// AutoserveApi.browseSpareParts.
class ShopFilters {
  const ShopFilters({this.make, this.model, this.category, this.year, this.query = ''});

  final String? make;
  final String? model;
  final String? category;
  final int? year;
  final String query;

  ShopFilters copyWith({
    Object? make = _unset,
    Object? model = _unset,
    Object? category = _unset,
    Object? year = _unset,
    String? query,
  }) =>
      ShopFilters(
        make: make == _unset ? this.make : make as String?,
        model: model == _unset ? this.model : model as String?,
        category: category == _unset ? this.category : category as String?,
        year: year == _unset ? this.year : year as int?,
        query: query ?? this.query,
      );

  static const _unset = Object();
}

final shopFiltersProvider = StateProvider.autoDispose<ShopFilters>((ref) => const ShopFilters());

final _sparePartsProvider = FutureProvider.autoDispose<List<SparePartSummary>>((ref) {
  final f = ref.watch(shopFiltersProvider);
  return ref.watch(autoserveApiProvider).browseSpareParts(
        make: f.make,
        model: f.model,
        category: f.category,
        year: f.year,
      );
});

final _partsFacetsProvider =
    FutureProvider.autoDispose<({List<String> makes, List<String> models})>((ref) {
  return ref.watch(autoserveApiProvider).getPartsFacets();
});

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = ref.watch(_sparePartsProvider);
    final filters = ref.watch(shopFiltersProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search parts by name or SKU',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) =>
                ref.read(shopFiltersProvider.notifier).state = filters.copyWith(query: v),
          ),
        ),
        const SizedBox(height: 8),
        const _FacetFilterBar(),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(_sparePartsProvider),
            child: parts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(_sparePartsProvider),
                  child: const Text('Could not load parts — tap to retry'),
                ),
              ),
              data: (items) {
                final query = filters.query.trim().toLowerCase();
                final visible = query.isEmpty
                    ? items
                    : items
                        .where((p) =>
                            p.title.toLowerCase().contains(query) ||
                            p.sku.toLowerCase().contains(query))
                        .toList();
                if (visible.isEmpty) {
                  return ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No parts match your search/filters.')),
                      ),
                    ],
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, i) => _PartCard(part: visible[i]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FacetFilterBar extends ConsumerWidget {
  const _FacetFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facets = ref.watch(_partsFacetsProvider);
    final filters = ref.watch(shopFiltersProvider);

    return facets.when(
      loading: () => const SizedBox(height: 40),
      error: (e, _) => const SizedBox.shrink(),
      data: (f) {
        if (f.makes.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final make in f.makes)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(make),
                    selected: filters.make == make,
                    onSelected: (selected) => ref.read(shopFiltersProvider.notifier).state =
                        filters.copyWith(make: selected ? make : null),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PartCard extends ConsumerWidget {
  const _PartCard({required this.part});
  final SparePartSummary part;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outOfStock = part.stockQuantity <= 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/customer/shop/${part.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(Icons.build_circle_outlined,
                      size: 48, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                ),
              ),
              Text(part.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall),
              Text(part.sku, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TZS ${part.price}', style: Theme.of(context).textTheme.labelLarge),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    tooltip: outOfStock ? 'Out of stock' : 'Add to cart',
                    onPressed: outOfStock
                        ? null
                        : () async {
                            await ref.read(cartControllerProvider.notifier).add(sparePartId: part.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${part.title} added to cart')),
                            );
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
