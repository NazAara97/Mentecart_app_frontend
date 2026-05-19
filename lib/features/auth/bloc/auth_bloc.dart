import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/api/api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc(this.apiService) : super(AuthInitial()) {
    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final response =
            await apiService.signup(event.email, event.password);

        final token = response.data["token"];

        emit(AuthSuccess(token));
      } catch (e) {
        emit(AuthError("Signup failed"));
      }
    });
  }
}