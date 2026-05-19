abstract class ServiceEvent {}

class FetchServicesEvent extends ServiceEvent {}

class FetchServiceByIdEvent extends ServiceEvent {
  final String id;

  FetchServiceByIdEvent(this.id);
}