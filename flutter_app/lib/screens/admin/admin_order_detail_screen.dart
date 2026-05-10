import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';
import '../../screens/magasin/orders_screen.dart' show StatusBadge;

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  OrderModel? _order;
  List<OrderItemModel> _items = [];
  bool _loading = true;
  bool _updating = false;

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
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _updating = true);
    try {
      await OrderService.updateStatus(widget.orderId, status);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: $status'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    }
    if (mounted) setState(() => _updating = false);
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
                      // Magasin info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Informations Magasin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 12),
                              if (_order!.magasinName != null) _InfoRow(Icons.store_outlined, _order!.magasinName!),
                              if (_order!.userName != null) _InfoRow(Icons.person_outline, _order!.userName!),
                              if (_order!.phone != null) _InfoRow(Icons.phone_outlined, _order!.phone!),
                              if (_order!.address != null) _InfoRow(Icons.location_on_outlined, _order!.address!),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Status timeline
                      _StatusTimeline(status: _order!.status),
                      const SizedBox(height: 12),
                      // Items
                      const Text('Produits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      ..._items.map((item) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                              ),
                              title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text('${item.quantity} × ${formatPrice(item.unitPrice)}'),
                              trailing: Text(formatPrice(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                          )),
                      const SizedBox(height: 12),
                      // Summary
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _SummaryRow('Sous-total', formatPrice(_order!.totalAmount)),
                              if (_order!.pointsUsed > 0) ...[
                                _SummaryRow('Points utilisés', '-${_order!.pointsUsed} pts', color: AppColors.warning),
                                _SummaryRow('Remise', '-${formatPrice(_order!.discountAmount)}', color: AppColors.success),
                              ],
                              const Divider(),
                              _SummaryRow('Total final', formatPrice(_order!.finalTotal), bold: true, color: AppColors.primary),
                              if (_order!.pointsEarned > 0) ...[
                                const SizedBox(height: 8),
                                Row(children: [
                                  const Icon(Icons.stars, color: AppColors.warning, size: 16),
                                  const SizedBox(width: 6),
                                  Text('+${_order!.pointsEarned} points accordés', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
                                ]),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Status update buttons
                      const Text('Mettre à jour le statut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      if (_updating)
                        const Center(child: CircularProgressIndicator())
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.orderStatuses.map((s) {
                            final isCurrent = _order!.status == s;
                            return ElevatedButton(
                              onPressed: isCurrent ? null : () => _updateStatus(s),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrent ? AppColors.primary : Colors.white,
                                foregroundColor: isCurrent ? Colors.white : AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                              child: Text(s),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _SummaryRow(this.label, this.value, {this.bold = false, this.color});

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
