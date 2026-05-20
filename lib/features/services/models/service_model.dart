class Service {
  final String id;
  final String title;
  final double price;
  final String description;
  final String category;
  final int duration;
  final String? image;

  Service({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.duration,
    this.image,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? "",
      title: json['title'] ?? "",
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? "",
      category: json['category'] ?? "Others",
      duration: json['duration'] ?? 0,
      image: json['image'],
    );
  }

  factory Service.empty() {
    return Service(
      id: "",
      title: "Unknown Service",
      price: 0,
      description: "",
      category: "",
      duration: 0,
      image: null,
    );
  }
}