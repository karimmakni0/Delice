import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'points_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _screens = const [
    ProductsScreen(),
    CartScreen(),
    OrdersScreen(),
    PointsScreen(),
    ProfileScreen(),
  ];

  final _titles = const [
    'Délice Distribution',
    'Mon Panier',
    'Mes Commandes',
    'Mes Points',
    'Mon Profil',
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartCount = cart.itemCount;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (_index == 0) // Show cart count only on products screen
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '$cartCount articles',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          if (_index == 1 && cart.items.isNotEmpty) // Cart tab action
            TextButton(
              onPressed: cart.clear,
              child: const Text('Vider', style: TextStyle(color: Colors.white70)),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Produits'),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: cartCount > 0,
              badgeContent: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Panier',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Commandes'),
          const BottomNavigationBarItem(icon: Icon(Icons.stars_outlined), label: 'Points'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
