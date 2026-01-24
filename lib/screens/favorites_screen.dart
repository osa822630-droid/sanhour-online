import 'package:flutter/material.dart';
import '../providers/shops_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/search_bar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final shopsProvider = Provider.of<ShopsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'محلات'),
            Tab(text: 'منتجات'),
            Tab(text: 'عروض'),
          ],
        ),
      ),
      body: Column(
        children: [
          const SearchBarWidget(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // تبويب المحلات المفضلة
                shopsProvider.favoriteShops.isEmpty
                    ? const Center(child: Text('لا توجد محلات في المفضلة'))
                    : ListView.builder(
                        itemCount: shopsProvider.favoriteShops.length,
                        itemBuilder: (context, index) {
                          final shop = shopsProvider.favoriteShops[index];
                          return ListTile(
                            leading: Image.network(shop.imageUrl),
                            title: Text(shop.name),
                            subtitle: Text('${shop.rating} ⭐'),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () =>
                                  shopsProvider.toggleShopFavorite(shop.id),
                            ),
                          );
                        },
                      ),

                // تبويب المنتجات المفضلة
                shopsProvider.favoriteProducts.isEmpty
                    ? const Center(child: Text('لا توجد منتجات في المفضلة'))
                    : ListView.builder(
                        itemCount: shopsProvider.favoriteProducts.length,
                        itemBuilder: (context, index) {
                          final product = shopsProvider.favoriteProducts[index];
                          return ListTile(
                            leading: Image.network(product.imageUrls.isNotEmpty
                                ? product.imageUrls.first
                                : 'https://via.placeholder.com/50'),
                            title: Text(product.name),
                            subtitle: Text('${product.price} جنيه'),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => shopsProvider
                                  .toggleProductFavorite(product.id),
                            ),
                          );
                        },
                      ),

                // تبويب العروض المفضلة
                shopsProvider.favoriteOffers.isEmpty
                    ? const Center(child: Text('لا توجد عروض في المفضلة'))
                    : ListView.builder(
                        itemCount: shopsProvider.favoriteOffers.length,
                        itemBuilder: (context, index) {
                          final offer = shopsProvider.favoriteOffers[index];
                          return ListTile(
                            leading: Image.network(offer.imageUrl),
                            title: Text(offer.title),
                            subtitle: Text('خصم ${offer.discount}%'),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () =>
                                  shopsProvider.toggleOfferFavorite(offer.id),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
