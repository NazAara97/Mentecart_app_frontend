import 'package:flutter/material.dart';

abstract class CartEvent {}

class FetchCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String serviceId;
  final DateTime date;
  final TimeOfDay time;

  AddToCartEvent({
    required this.serviceId,
    required this.date,
    required this.time,
  });
}

class RemoveCartItemEvent extends CartEvent {
  final String itemId;

  RemoveCartItemEvent(this.itemId);
}


class UpdateCartItemEvent extends CartEvent {
  final String itemId;
  final int quantity;
  
  var serviceId;
  

  UpdateCartItemEvent(this.itemId, this.quantity ,this.serviceId);
  
  
  
  
  
  

  

  
}

class ClearCartEvent extends CartEvent {}