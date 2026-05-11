import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _products = await ProductService.adminGetProducts();
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showForm({ProductModel? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ProductForm(product: product, onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _products.length,
                itemBuilder: (ctx, i) {
                  final p = _products[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: p.isActive ? AppColors.primary.withOpacity(0.08) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.inventory_2_outlined, color: p.isActive ? AppColors.primary : Colors.grey),
                      ),
                      title: Text(p.name, style: TextStyle(fontWeight: FontWeight.w600, color: p.isActive ? null : AppColors.textSecondary)),
                      subtitle: Text('${p.category ?? ''} • Stock: ${p.stock}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatPrice(p.price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                            onPressed: () => _showForm(product: p),
                          ),
                          IconButton(
                            icon: Icon(p.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: p.isActive ? AppColors.danger : AppColors.success),
                            onPressed: () async {
                              await ProductService.updateProduct(p.id, {'is_active': !p.isActive});
                              _load();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final ProductModel? product;
  final VoidCallback onSaved;
  const _ProductForm({this.product, required this.onSaved});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  late final _descCtrl = TextEditingController(text: widget.product?.description);
  late final _catCtrl = TextEditingController(text: widget.product?.category);
  late final _priceCtrl = TextEditingController(text: widget.product?.price.toString());
  late final _stockCtrl = TextEditingController(text: widget.product?.stock.toString());
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _catCtrl.dispose();
    _priceCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final body = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category': _catCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text),
      'stock': int.parse(_stockCtrl.text),
    };
    try {
      if (widget.product != null) {
        await ProductService.updateProduct(widget.product!.id, body);
      } else {
        await ProductService.createProduct(body);
      }
      if (mounted) Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.product == null ? 'Ajouter un produit' : 'Modifier le produit',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nom *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              const SizedBox(height: 12),
              TextFormField(controller: _catCtrl, decoration: const InputDecoration(labelText: 'Catégorie')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Prix (DT) *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Invalide' : null),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stock *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Invalide' : null),
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Enregistrer'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
