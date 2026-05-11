import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<ProductProvider>().setSearch('');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => context.read<ProductProvider>().setSearch(v),
          ),
        ),
        // Category filter
        if (provider.categories.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(label: 'Tous', selected: provider.selectedCategory == null, onTap: () => provider.setCategory(null)),
                ...provider.categories.map((c) => _CategoryChip(
                      label: c,
                      selected: provider.selectedCategory == c,
                      onTap: () => provider.setCategory(c),
                    )),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Products grid
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.products.isEmpty
                  ? const Center(child: Text('Aucun produit trouvé'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: provider.products.length,
                      itemBuilder: (ctx, i) => _ProductCard(
                        product: provider.products[i],
                        cartQty: cart.getQty(provider.products[i].id),
                        onAdd: (qty) => cart.add(provider.products[i], qty),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final int cartQty;
  final void Function(int) onAdd;
  const _ProductCard({required this.product, required this.cartQty, required this.onAdd});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final outOfStock = widget.product.stock == 0;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primary.withOpacity(0.4)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.product.category != null)
                  Text(widget.product.category!, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(formatPrice(widget.product.price), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Stock: ${widget.product.stock}', style: TextStyle(fontSize: 11, color: outOfStock ? AppColors.danger : AppColors.textSecondary)),
                const SizedBox(height: 6),
                if (!outOfStock) ...[
                  Row(
                    children: [
                      _QtyBtn(icon: Icons.remove, onTap: () { if (_qty > 1) setState(() => _qty--); }),
                      Expanded(child: Center(child: Text('$_qty', style: const TextStyle(fontWeight: FontWeight.bold)))),
                      _QtyBtn(icon: Icons.add, onTap: () { if (_qty < widget.product.stock) setState(() => _qty++); }),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onAdd(_qty);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.product.name} ajouté'), duration: const Duration(seconds: 1)),
                        );
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6)),
                      child: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    child: const Text('Rupture de stock', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
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
