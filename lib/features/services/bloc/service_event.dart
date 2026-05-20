abstract class ServiceEvent {}
class FetchServicesEvent extends ServiceEvent {
  final String? category;
  final String? search;

  FetchServicesEvent({this.category, this.search});
}

class FetchServiceByIdEvent extends ServiceEvent {
  final String id;

  FetchServiceByIdEvent(this.id);
}

class FetchCategoriesEvent extends ServiceEvent {}