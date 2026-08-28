import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/autoserve_api.dart';
import '../../shared/models/cart_dto.dart';

/// Cart state lives here (not a per-screen FutureProvider like
/// myRequestsProvider) because it's read from multiple places at once —
/// the shop tab's cart badge, the cart screen, and checkout — and needs
/// mutation methods that refresh all of them together.
class CartController extends AsyncNotifier<CartDto> {
  @override
  Future<CartDto> build() => ref.watch(autoserveApiProvider).getCart();

  Future<void> add({required String sparePartId, int quantity = 1}) async {
    await ref.read(autoserveApiProvider).addToCart(sparePartId: sparePartId, quantity: quantity);
    await refresh();
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await ref.read(autoserveApiProvider).updateCartItem(cartItemId, quantity);
    await refresh();
  }

  Future<void> remove(String cartItemId) async {
    await ref.read(autoserveApiProvider).removeCartItem(cartItemId);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<CartDto>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => ref.read(autoserveApiProvider).getCart());
  }
}

final cartControllerProvider = AsyncNotifierProvider<CartController, CartDto>(CartController.new);

/// Derived item count for the shop tab's cart badge — 0 while loading/on
/// error rather than propagating those states into the badge UI.
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartControllerProvider);
  return cart.value?.items.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;
});
