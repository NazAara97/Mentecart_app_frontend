abstract class CartEvent {}

class FetchCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String serviceId;

  AddToCartEvent(this.serviceId);
}

class RemoveCartItemEvent extends CartEvent {
  final String itemId;

  RemoveCartItemEvent(this.itemId);
}


class UpdateCartItemEvent extends CartEvent {
  final String itemId;
  final int quantity;

  UpdateCartItemEvent(this.itemId, this.quantity);
}

class ClearCartEvent extends CartEvent {}