class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // Points logic
  static const int pointsPerDt = 1;
  static const int pointsForDiscount = 100;
  static const double discountPerBlock = 5.0;

  // Order statuses
  static const List<String> orderStatuses = [
    'En attente',
    'En préparation',
    'En livraison',
    'Livré',
    'Annulé',
  ];
}
