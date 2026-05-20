import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/booking/bloc/book_event.dart';
import 'package:mentecart_app/features/booking/bloc/book_state.dart';
import 'package:mentecart_app/features/booking/data/booking_api.dart';
import '../models/booking_model.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingApi api;

  BookingBloc(this.api) : super(BookingInitial()) {

    // ✅ EVENTS
    on<CreateBookingEvent>(_createBooking);
    on<FetchBookingsEvent>(_fetchBookings);
    on<CancelBookingEvent>(_cancelBooking);
    on<GetBookingByIdEvent>(_getBookingById);

    // ✅ NEW PAYMENT EVENTS
    on<PayCashEvent>(_payCash);
    on<PayCardEvent>(_payCard);
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
        event.items,
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
      final res = await api.getBookingById(event.bookingId, {});

      final booking = Booking.fromJson(res);

      emit(BookingLoaded(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ---------------- 💵 PAY WITH CASH ----------------
  Future<void> _payCash(
    PayCashEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final res = await api.payWithCash(event.bookingId);

      final booking = Booking.fromJson(res["booking"]);

      emit(BookingPaymentSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ---------------- 💳 PAY WITH CARD ----------------
  Future<void> _payCard(
    PayCardEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final res = await api.payWithCard(
        bookingId: event.bookingId,
        cardHolderName: event.cardHolderName,
        cardNumber: event.cardNumber,
        expiryMonth: event.expiryMonth,
        expiryYear: event.expiryYear,
      );

      final booking = Booking.fromJson(res["booking"]);

      emit(BookingPaymentSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ---------------- ❌ CANCEL BOOKING ----------------
  Future<void> _cancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      await api.cancelBooking(event.bookingId);

      emit(BookingCancelSuccess());
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}