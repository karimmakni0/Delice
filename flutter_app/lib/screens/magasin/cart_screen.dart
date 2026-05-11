import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _usePoints = false;
  bool _loading = false;

  int get _availablePoints => context.read<AuthProvider>().user?.pointsBalance ?? 0;

  // Max usable points (must be multiple of 100)
  int get _maxUsablePoints {
    final cart = context.read<CartProvider>();
    final total = cart.totalAmount;
    final maxByTotal = (total / AppConstants.discountPerBlock).floor() * AppConstants.pointsForDiscount;
    return (_availablePoints ~/ 100) * 100 < maxByTotal
        ? (_availablePoints ~/ 100) * 100
        : maxByTotal;
  }

  int get _pointsToUse => _usePoints ? _maxUsablePoints : 0;
  double get _discount => (_pointsToUse / AppConstants.pointsForDiscount) * AppConstants.discountPerBlock;

  Future<void> _confirmOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;
    setState(() => _loading = true);
    try {
      final items = cart.items.map((i) => {
        'product_id': i.product.id,
        'quantity': i.quantity,
      }).toList();
      await OrderService.createOrder(items, _pointsToUse);
      if (mounted) {
        await context.read<AuthProvider>().refreshUser();
      }
      cart.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande confirmée !'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalAmount;
    final finalTotal = total - _discount;

    if (cart.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Votre panier est vide', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cart.items.length,
            itemBuilder: (ctx, i) {
              final item = cart.items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(formatPrice(item.product.price), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _QtyBtn(icon: Icons.remove, onTap: () => cart.updateQty(item.product.id, item.quantity - 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          _QtyBtn(icon: Icons.add, onTap: () => cart.updateQty(item.product.id, item.quantity + 1)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(formatPrice(item.product.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        onPressed: () => cart.remove(item.product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: Column(
            children: [
              _SummaryRow('Total', formatPrice(total)),
              if (_availablePoints > 0) ...[
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Utiliser mes points ($_availablePoints pts disponibles)')),
                    Switch(
                      value: _usePoints,
                      onChanged: _maxUsablePoints > 0 ? (v) => setState(() => _usePoints = v) : null,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                if (_usePoints) ...[
                  _SummaryRow('Points utilisés', '-$_pointsToUse pts', color: AppColors.warning),
                  _SummaryRow('Remise', '-${formatPrice(_discount)}', color: AppColors.success),
                ],
              ],
              const Divider(),
              _SummaryRow('Total final', formatPrice(finalTotal), bold: true, color: AppColors.primary),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _confirmOrder,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Confirmer la commande'),
                ),
              ),
            ],
          ),
        ),
      ],
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
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
