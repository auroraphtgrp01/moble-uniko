class Category {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? fundId;
  final String trackerType;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.fundId,
    required this.trackerType,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      fundId: json['fundId'],
      trackerType: json['trackerType'],
    );
  }
}

class CategoryResponse {
  final List<Category> data;

  CategoryResponse({required this.data});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      data: (json['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
    );
  }
}
