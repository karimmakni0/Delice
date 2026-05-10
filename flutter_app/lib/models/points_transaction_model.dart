class PointsTransaction {
  final int id;
  final int orderId;
  final String type;
  final int points;
  final double? amountValue;
  final String createdAt;

  PointsTransaction({
    required this.id,
    required this.orderId,
    required this.type,
    required this.points,
    this.amountValue,
    required this.createdAt,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> j) => PointsTransaction(
        id: j['id'],
        orderId: j['order_id'] ?? 0,
        type: j['type'],
        points: j['points'],
        amountValue: j['amount_value'] != null ? double.parse(j['amount_value'].toString()) : null,
        createdAt: j['created_at'] ?? '',
      );
}
