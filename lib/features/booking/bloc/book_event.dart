import 'package:mentecart_app/features/booking/bloc/book_state.dart';

abstract class BookingEvent {}

class CreateBookingEvent extends BookingEvent {
  final DateTime appointmentDate;
  final List items;

  CreateBookingEvent(
    this.appointmentDate,
    this.items,
  );
}

class FetchBookingsEvent extends BookingEvent {}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  CancelBookingEvent(this.bookingId);
}
class GetBookingByIdEvent extends BookingEvent {
  final String bookingId;

  GetBookingByIdEvent(this.bookingId);
}

class BookingPaymentSuccess extends BookingState {}
class BookingLoaded extends BookingState {
  final dynamic booking;
  BookingLoaded(this.booking);
}

class PayBookingEvent extends BookingEvent {
  final String bookingId;
  final String method;
  final String transactionId;

  final String cardHolderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;

  PayBookingEvent({
    required this.bookingId,
    required this.method,
    required this.transactionId,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
  });
}