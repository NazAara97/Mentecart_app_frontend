import 'package:mentecart_app/features/cart/models/cart_model.dart';


abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Cart cart;

  CartLoaded(this.cart);

  get cartItems => null;

  get items => null;
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}