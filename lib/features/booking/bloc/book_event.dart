import 'package:mentecart_app/features/booking/bloc/book_state.dart';
import 'package:mentecart_app/features/booking/models/booking_model.dart';

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

class BookingPaymentSuccess extends BookingState {
  BookingPaymentSuccess(Booking booking);
}
class BookingLoaded extends BookingState {
  final dynamic booking;
  BookingLoaded(this.booking);
}

class PayCashEvent extends BookingEvent {
  final String bookingId;
  PayCashEvent(this.bookingId);
}

class PayCardEvent extends BookingEvent {
  final String bookingId;
  final String cardHolderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;

  PayCardEvent({
    required this.bookingId,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
  });
}