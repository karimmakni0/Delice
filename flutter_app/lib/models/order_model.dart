class OrderModel {
  final int id;
  final int userId;
  final double totalAmount;
  final int pointsUsed;
  final double discountAmount;
  final double finalTotal;
  final int pointsEarned;
  final String status;
  final String createdAt;
  // Admin-joined fields
  final String? magasinName;
  final String? userName;
  final String? phone;
  final String? address;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.pointsUsed,
    required this.discountAmount,
    required this.finalTotal,
    required this.pointsEarned,
    required this.status,
    required this.createdAt,
    this.magasinName,
    this.userName,
    this.phone,
    this.address,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'],
        userId: j['user_id'],
        totalAmount: double.parse(j['total_amount'].toString()),
        pointsUsed: j['points_used'] ?? 0,
        discountAmount: double.parse(j['discount_amount'].toString()),
        finalTotal: double.parse(j['final_total'].toString()),
        pointsEarned: j['points_earned'] ?? 0,
        status: j['status'],
        createdAt: j['created_at'] ?? '',
        magasinName: j['magasin_name'],
        userName: j['name'],
        phone: j['phone'],
        address: j['address'],
      );
}

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final String? category;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    this.category,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        id: j['id'],
        productId: j['product_id'],
        productName: j['name'],
        productImage: j['image'],
        category: j['category'],
        quantity: j['quantity'],
        unitPrice: double.parse(j['unit_price'].toString()),
        subtotal: double.parse(j['subtotal'].toString()),
      );
}
