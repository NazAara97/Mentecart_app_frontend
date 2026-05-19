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
    required this.description,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
    );
  }

 

  
}