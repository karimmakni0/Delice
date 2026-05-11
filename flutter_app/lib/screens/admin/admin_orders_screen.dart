import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../screens/magasin/orders_screen.dart' show StatusBadge;
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAdminOrders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(hintText: 'Rechercher par magasin...', prefixIcon: Icon(Icons.search)),
            onChanged: (v) => provider.loadAdminOrders(search: v),
          ),
        ),
        // Status filter
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _FilterChip(label: 'Tous', selected: provider.statusFilter == null, onTap: () => provider.setStatusFilter(null)),
              ...AppConstants.orderStatuses.map((s) => _FilterChip(
                    label: s,
                    selected: provider.statusFilter == s,
                    onTap: () => provider.setStatusFilter(s),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.orders.isEmpty
                  ? const Center(child: Text('Aucune commande'))
                  : RefreshIndicator(
                      onRefresh: () => provider.loadAdminOrders(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.orders.length,
                        itemBuilder: (ctx, i) => _AdminOrderCard(order: provider.orders[i]),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(orderId: order.id))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.magasinName ?? order.userName ?? 'Magasin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 6),
              if (order.phone != null)
                Row(children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(order.phone!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ]),
              if (order.address != null)
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(order.address!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                ]),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Commande #${order.id} • ${formatDate(order.createdAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(formatPrice(order.finalTotal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
