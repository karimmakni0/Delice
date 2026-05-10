class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? category;
  final double price;
  final int stock;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.category,
    required this.price,
    required this.stock,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'],
        name: j['name'],
        description: j['description'],
        image: j['image'],
        category: j['category'],
        price: double.parse(j['price'].toString()),
        stock: j['stock'],
        isActive: j['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'image': image,
        'category': category,
        'price': price,
        'stock': stock,
        'is_active': isActive,
      };
}
