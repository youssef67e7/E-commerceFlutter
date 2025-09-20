class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle potential null values and type conversions more safely
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Unknown Product';
    final description = json['description']?.toString() ?? 'No description available';
    final price = (json['price'] is num) ? json['price'].toDouble() : 0.0;
    final images = json['images'] as List<dynamic>?;
    final thumbnail = json['thumbnail']?.toString();
    final imageUrl = thumbnail ?? (images?.isNotEmpty == true ? images![0]?.toString() : '') ?? '';
    final category = json['category']?.toString() ?? 'Uncategorized';
    final rating = (json['rating'] is num) ? json['rating'].toDouble() : 0.0;
    // Fix review count - it should come from a 'reviewCount' field, not 'reviews' array
    final reviewCount = (json['reviewCount'] is int) ? json['reviewCount'] : 
                     (json['reviews'] is List<dynamic> ? json['reviews'].length : 0);

    return Product(
      id: id,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}