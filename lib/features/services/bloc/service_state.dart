import 'package:mentecart_app/features/services/models/service_model.dart';



abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<Service> services;

  ServiceLoaded(this.services);
}

class ServiceError extends ServiceState {
  final String message;

  ServiceError(this.message);
}


class ServiceDetailLoading extends ServiceState {}

class ServiceDetailLoaded extends ServiceState {
  final Service service;

  ServiceDetailLoaded(this.service);
}

class ServiceDetailError extends ServiceState {
  final String message;

  ServiceDetailError(this.message);
}

class CategoriesLoaded extends ServiceState {
  final List<String> categories;

  CategoriesLoaded(this.categories);
}