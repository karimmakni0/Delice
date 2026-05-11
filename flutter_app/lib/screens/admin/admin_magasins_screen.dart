import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/order_service.dart';

class AdminMagasinsScreen extends StatefulWidget {
  const AdminMagasinsScreen({super.key});

  @override
  State<AdminMagasinsScreen> createState() => _AdminMagasinsScreenState();
}

class _AdminMagasinsScreenState extends State<AdminMagasinsScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _magasins = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _magasins = await OrderService.adminGetMagasins(search: _searchCtrl.text.trim());
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Rechercher un magasin...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => _load(),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _magasins.isEmpty
                  ? const Center(child: Text('Aucun magasin trouvé'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _magasins.length,
                        itemBuilder: (ctx, i) {
                          final m = _magasins[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text((m.magasinName ?? m.name)[0].toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(m.magasinName ?? m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (m.magasinName != null) Text(m.name, style: const TextStyle(fontSize: 12)),
                                  if (m.phone != null) Row(children: [const Icon(Icons.phone, size: 12), const SizedBox(width: 4), Text(m.phone!, style: const TextStyle(fontSize: 12))]),
                                  if (m.address != null) Row(children: [const Icon(Icons.location_on, size: 12), const SizedBox(width: 4), Expanded(child: Text(m.address!, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))]),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.stars, color: AppColors.warning, size: 16),
                                  Text('${m.pointsBalance}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                                  const Text('pts', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
