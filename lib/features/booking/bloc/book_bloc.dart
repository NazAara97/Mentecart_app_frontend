import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/booking/bloc/book_event.dart';
import 'package:mentecart_app/features/booking/bloc/book_state.dart';
import 'package:mentecart_app/features/booking/data/booking_api.dart';
import '../models/booking_model.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingApi api;

  BookingBloc(this.api) : super(BookingInitial()) {
    on<CreateBookingEvent>(_createBooking);
    on<FetchBookingsEvent>(_fetchBookings);
    on<CancelBookingEvent>(_cancelBooking);
    on<PayBookingEvent>(_payBooking);
    on<GetBookingByIdEvent>(_getBookingById); // ✅ FIX ADDED
  }

  // ---------------- CREATE BOOKING ----------------
  Future<void> _createBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final res = await api.checkout(
        event.appointmentDate,
        event.items, // ✅ FIXED (no casting)
      );

      final booking = Booking.fromJson(res);

      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ---------------- GET ALL BOOKINGS ----------------
  Future<void> _fetchBookings(
    FetchBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final res = await api.getBookings();

      final bookings =
          res.map<Booking>((e) => Booking.fromJson(e)).toList();

      emit(BookingListLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ---------------- GET SINGLE BOOKING ----------------
  Future<void> _getBookingById(
    GetBookingByIdEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      // pass a second argument to match BookingApi.getBookingById signature
      final res = await api.getBookingById(event.bookingId, {});

      final booking = Booking.fromJson(res);

      emit(BookingLoaded(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ---------------- CANCEL BOOKING ----------------
 Future<void> _cancelBooking(
  CancelBookingEvent event,
  Emitter<BookingState> emit,
) async {
  emit(BookingLoading());

  try {
    await api.cancelBooking(event.bookingId);

    emit(BookingCancelSuccess()); // ✅ emit success
  } catch (e) {
    emit(BookingError(e.toString()));
  }
}

  // ---------------- PAYMENT ----------------
 Future<void> _payBooking(
  PayBookingEvent event,
  Emitter<BookingState> emit,
) async {
  emit(BookingLoading());

  try {
    await api.payment(
      event.bookingId,
      event.method,
      event.transactionId,
      cardHolderName: event.cardHolderName,
      cardNumber: event.cardNumber,
      expiryMonth: event.expiryMonth,
      expiryYear: event.expiryYear,
    );

    emit(BookingPaymentSuccess()); // ✅ emit success ONLY
  } catch (e) {
    emit(BookingError(e.toString()));
  }
}
}