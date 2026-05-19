import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentecart_app/features/services/data/service_api.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceApi api;

  ServiceBloc(this.api) : super(ServiceInitial()) {

    // 📌 Get all services
    on<FetchServicesEvent>(_onFetchServices);

    // 📌 Get service by ID
    on<FetchServiceByIdEvent>(_onFetchServiceById);
  }

  // =========================
  // GET ALL SERVICES
  // =========================
  Future<void> _onFetchServices(
    FetchServicesEvent event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());

    try {
      final services = await api.fetchServices();
      emit(ServiceLoaded(services));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  // =========================
  // GET SERVICE BY ID
  // =========================
  Future<void> _onFetchServiceById(
    FetchServiceByIdEvent event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceDetailLoading());

    try {
      final service = await api.fetchServiceById(event.id);
      emit(ServiceDetailLoaded(service));
    } catch (e) {
      emit(ServiceDetailError(e.toString()));
    }
  }
}