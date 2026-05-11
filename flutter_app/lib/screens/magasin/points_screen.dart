import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/points_provider.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PointsProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Balance card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 48),
                const SizedBox(height: 8),
                Text('${provider.balance}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const Text('points disponibles', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(provider.balance ~/ 100) * 5} DT de remise disponible',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Comment ça marche ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  _InfoRow(Icons.shopping_bag_outlined, '1 DT dépensé = 1 point gagné'),
                  _InfoRow(Icons.stars_outlined, '100 points = 5 DT de remise'),
                  _InfoRow(Icons.local_shipping_outlined, 'Points crédités à la livraison'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (provider.history.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Aucune transaction', style: TextStyle(color: AppColors.textSecondary))))
          else
            ...provider.history.map((t) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.type == 'EARN' ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
                      child: Icon(
                        t.type == 'EARN' ? Icons.add : Icons.remove,
                        color: t.type == 'EARN' ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    title: Text(t.type == 'EARN' ? 'Points gagnés' : 'Points utilisés', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Commande #${t.orderId} • ${formatDate(t.createdAt)}', style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      '${t.type == 'EARN' ? '+' : '-'}${t.points} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.type == 'EARN' ? AppColors.success : AppColors.warning,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
