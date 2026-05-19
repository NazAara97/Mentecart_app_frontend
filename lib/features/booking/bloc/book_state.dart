import 'package:mentecart_app/features/booking/models/booking_model.dart';



abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final Booking booking;
  BookingSuccess(this.booking);
}



class BookingCancelSuccess extends BookingState {}

class BookingListLoaded extends BookingState {
  final List<Booking> bookings;
  BookingListLoaded(this.bookings);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}