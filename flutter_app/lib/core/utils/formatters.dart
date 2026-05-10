import 'package:intl/intl.dart';

String formatPrice(dynamic price) {
  final n = double.tryParse(price.toString()) ?? 0;
  return '${n.toStringAsFixed(3)} DT';
}

String formatDate(String? dateStr) {
  if (dateStr == null) return '';
  try {
    final dt = DateTime.parse(dateStr).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  } catch (_) {
    return dateStr;
  }
}
