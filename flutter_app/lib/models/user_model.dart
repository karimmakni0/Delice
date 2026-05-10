class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? magasinName;
  final String? phone;
  final String? address;
  final int pointsBalance;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.magasinName,
    this.phone,
    this.address,
    required this.pointsBalance,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        role: j['role'],
        magasinName: j['magasin_name'],
        phone: j['phone'],
        address: j['address'],
        pointsBalance: j['points_balance'] ?? 0,
      );
}
