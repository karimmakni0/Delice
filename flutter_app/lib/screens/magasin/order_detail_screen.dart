import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'orders_screen.dart' show StatusBadge;

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  List<OrderItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await OrderService.getOrderDetail(widget.orderId);
      setState(() {
        _order = data['order'];
        _items = data['items'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Commande #${widget.orderId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Commande introuvable'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status timeline
                      _StatusTimeline(status: _order!.status),
                      const SizedBox(height: 16),
                      // Items
                      const Text('Produits commandés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ..._items.map((item) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text('${item.quantity} × ${formatPrice(item.unitPrice)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Text(formatPrice(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      // Summary
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _Row('Sous-total', formatPrice(_order!.totalAmount)),
                              if (_order!.pointsUsed > 0) ...[
                                _Row('Points utilisés', '-${_order!.pointsUsed} pts', color: AppColors.warning),
                                _Row('Remise', '-${formatPrice(_order!.discountAmount)}', color: AppColors.success),
                              ],
                              const Divider(),
                              _Row('Total final', formatPrice(_order!.finalTotal), bold: true, color: AppColors.primary),
                              if (_order!.pointsEarned > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.stars, color: AppColors.warning, size: 18),
                                    const SizedBox(width: 6),
                                    Text('+${_order!.pointsEarned} points gagnés', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _Row(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 15 : 14, color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: style), Text(value, style: style)]),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  static const _steps = ['En attente', 'En préparation', 'En livraison', 'Livré'];

  int get _currentIndex {
    if (status == 'Annulé') return -1;
    return _steps.indexOf(status);
  }

  @override
  Widget build(BuildContext context) {
    if (status == 'Annulé') {
      return Card(
        color: AppColors.danger.withOpacity(0.1),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColors.danger),
              SizedBox(width: 8),
              Text('Commande annulée', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIdx = i ~/ 2;
              return Expanded(
                child: Container(
                  height: 2,
                  color: stepIdx < _currentIndex ? AppColors.primary : Colors.grey.shade300,
                ),
              );
            }
            final stepIdx = i ~/ 2;
            final done = stepIdx <= _currentIndex;
            return Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppColors.primary : Colors.grey.shade300,
                  ),
                  child: Icon(done ? Icons.check : Icons.circle, size: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(_steps[stepIdx].split(' ').last, style: TextStyle(fontSize: 9, color: done ? AppColors.primary : AppColors.textSecondary)),
              ],
            );
          }),
        ),
      ),
    );
  }
}
