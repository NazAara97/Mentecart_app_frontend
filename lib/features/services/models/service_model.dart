class Service {
  final String id;
  final String title;
  final double price;
  
  final String description;

  var image;

  Service({
    required this.id,
    required this.title,
    required this.price, 
    required this.description, required String category, required int duration,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'] ?? "",
      duration: json['duration'] ?? 0,
    );
  }

 factory Service.empty() {
  return Service(
    id: "",
    title: "Unknown Service",
    description: "",
    price: 0,
    duration: 0,
    category: "",
  );
}

 

  
}