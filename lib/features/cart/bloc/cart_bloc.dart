import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/cart/models/cart_model.dart';
import '../data/cart_api.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartApi api;

  CartBloc(this.api) : super(CartInitial()) {

    on<FetchCartEvent>(_onFetchCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveCartItemEvent>(_onRemoveItem);

    // ✅ ADD THIS (MISSING BEFORE)
    on<UpdateCartItemEvent>(_onUpdateItem);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onClearCart(
  ClearCartEvent event,
  Emitter<CartState> emit,
) async {
  try {
    await api.clearCart(); // if backend exists

    emit(CartLoaded(Cart(items: []))); // empty cart
  } catch (e) {
    emit(CartError(e.toString()));
  }
}

  // GET CART
  Future<void> _onFetchCart(
      FetchCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());

    try {
      final Cart cart = await api.fetchCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  // ADD ITEM
 Future<void> _onAddToCart(
  AddToCartEvent event,
  Emitter<CartState> emit,
) async {
  try {
    await api.addToCart(
      event.serviceId,
      event.date,
      event.time,
    );

    add(FetchCartEvent());
  } catch (e) {
    emit(CartError(e.toString()));
  }
}
  // REMOVE ITEM
  Future<void> _onRemoveItem(
      RemoveCartItemEvent event, Emitter<CartState> emit) async {
    try {
      await api.removeItem(event.itemId);
      add(FetchCartEvent());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  // ✅ UPDATE QUANTITY (NEW FIX)
  Future<void> _onUpdateItem(
      UpdateCartItemEvent event, Emitter<CartState> emit) async {
    try {
      await api.updateCartItem(
        event.itemId,
        event.quantity,
        
      );

      // refresh cart after update
      add(FetchCartEvent());

    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}


