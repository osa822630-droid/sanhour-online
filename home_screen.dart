import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shops_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_list.dart';
import '../widgets/ad_carousel.dart';
import '../widgets/horizontal_list.dart';
import 'category_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final shopsProvider = Provider.of<ShopsProvider>(context, listen: false);
    await shopsProvider.loadShops(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanhour Online'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: تنفيذ الفلترة
            },
            tooltip: 'فلترة النتائج',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final shopsProvider = Provider.of<ShopsProvider>(context, listen: false);
          await shopsProvider.loadShops(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SearchBarWidget(),
              const CategoryListWidget(),
              const SizedBox(height: 16),
              const AdCarousel(),
              const SizedBox(height: 16),
              Consumer<ShopsProvider>(
                builder: (context, shopsProvider, child) {
                  if (shopsProvider.isLoading && shopsProvider.shops.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (shopsProvider.error.isNotEmpty && shopsProvider.shops.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('خطأ: ${shopsProvider.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => shopsProvider.loadShops(refresh: true),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      const HorizontalList(title: 'المحلات المميزة', type: 'featured'),
                      const HorizontalList(title: 'الأكثر زيارة', type: 'top_visited'),
                      const HorizontalList(title: 'اكتشف جديد', type: 'discovery'),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة الرئيسية لقسم معين
class CategoryHomeScreen extends StatefulWidget {
  final String category;

  const CategoryHomeScreen({super.key, required this.category});

  @override
  State<CategoryHomeScreen> createState() => _CategoryHomeScreenState();
}

class _CategoryHomeScreenState extends State<CategoryHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الرئيسية'),
            Tab(text: 'المحلات'),
            Tab(text: 'العروض'),
            Tab(text: 'المنتجات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildShopsTab(),
          _buildOffersTab(),
          _buildProductsTab(),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        children: const [
          AdCarousel(),
          HorizontalList(title: 'الأكثر إضافة للمفضلة', type: 'favorites'),
          HorizontalList(title: 'الأكثر زيارة', type: 'top_visited'),
          HorizontalList(title: 'مناسب لك', type: 'recommended'),
        ],
      ),
    );
  }

  Widget _buildShopsTab() {
    return Consumer<ShopsProvider>(
      builder: (context, shopsProvider, child) {
        final categoryShops = shopsProvider.shops
            .where((shop) => shop.category == widget.category)
            .toList();

        if (shopsProvider.isLoading && categoryShops.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryShops.isEmpty) {
          return const Center(child: Text('لا توجد محلات في هذا القسم'));
        }

        return ListView.builder(
          itemCount: categoryShops.length,
          itemBuilder: (context, index) {
            final shop = categoryShops[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(shop.imageUrl),
              ),
              title: Text(shop.name),
              subtitle: Text('${shop.rating} ⭐ (${shop.views} مشاهدة)'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: الانتقال لصفحة المحل
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOffersTab() {
    return Consumer<ShopsProvider>(
      builder: (context, shopsProvider, child) {
        final categoryOffers = shopsProvider.offers.where((offer) {
          final shop = shopsProvider.shops.firstWhere(
            (s) => s.id == offer.shopId,
            orElse: () => Shop(
              id: '',
              name: '',
              category: '',
              description: '',
              imageUrl: '',
              rating: 0,
              reviews: 0,
              views: 0,
              phone: '',
              location: '',
              isFeatured: false,
              workingDays: [],
              workingHours: '',
              deliveryStatus: '',
              deliveryTime: '',
            ),
          );
          return shop.category == widget.category;
        }).toList();

        if (categoryOffers.isEmpty) {
          return const Center(child: Text('لا توجد عروض في هذا القسم'));
        }

        return ListView.builder(
          itemCount: categoryOffers.length,
          itemBuilder: (context, index) {
            final offer = categoryOffers[index];
            return ListTile(
              leading: Image.network(offer.imageUrl),
              title: Text(offer.title),
              subtitle: Text('خصم ${offer.discount}%'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: الانتقال لصفحة العرض
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return Consumer<ShopsProvider>(
      builder: (context, shopsProvider, child) {
        final categoryProducts = shopsProvider.products
            .where((product) => product.category == widget.category)
            .toList();

        if (categoryProducts.isEmpty) {
          return const Center(child: Text('لا توجد منتجات في هذا القسم'));
        }

        return ListView.builder(
          itemCount: categoryProducts.length,
          itemBuilder: (context, index) {
            final product = categoryProducts[index];
            return ListTile(
              leading: Image.network(
                product.imageUrls.isNotEmpty 
                    ? product.imageUrls.first 
                    : 'https://via.placeholder.com/50'
              ),
              title: Text(product.name),
              subtitle: Text('${product.price} جنيه'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: الانتقال لصفحة المنتج
              },
            );
          },
        );
      },
    );
  }
}