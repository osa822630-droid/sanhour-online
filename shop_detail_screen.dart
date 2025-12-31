// lib/screens/shop_detail_screen.dart  // صفحة المحل
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop.dart';
import '../providers/shops_provider.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final shopsProvider = Provider.of<ShopsProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shop.name),
          actions: [
            IconButton(
              icon: Icon(
                shop.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: shop.isFavorite ? Colors.red : null,
              ),
              onPressed: () => shopsProvider.toggleShopFavorite(shop.id),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'نظرة عامة'),
              Tab(text: 'المنتجات'),
              Tab(text: 'التقييمات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // تبويب النظرة العامة
            _buildOverviewTab(context),
            // تبويب المنتجات
            _buildProductsTab(context),
            // تبويب التقييمات
            _buildReviewsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المحل
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(shop.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // اسم المحل والتقييم
          Row(
            children: [
              Expanded(
                child: Text(
                  shop.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                avatar: const Icon(Icons.star, color: Colors.amber, size: 16),
                label: Text('${shop.rating}'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // عدد التقييمات
          Text('${shop.reviews} تقييم', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),

          // وصف المحل
          Text(
            shop.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),

          // معلومات الاتصال
          _buildInfoSection(
            'معلومات الاتصال',
            Icons.contact_phone,
            [
              _buildInfoItem(Icons.phone, 'الهاتف', shop.phone),
              _buildInfoItem(Icons.location_on, 'الموقع', shop.location),
              _buildInfoItem(Icons.access_time, 'أوقات العمل', shop.workingHours),
              _buildInfoItem(Icons.delivery_dining, 'موعد التوصيل', shop.deliveryTime),
            ],
          ),

          const SizedBox(height: 24),

          // وسائل التواصل الاجتماعي
          if (shop.socialMedia.isNotEmpty)
            _buildInfoSection(
              'وسائل التواصل',
              Icons.share,
              shop.socialMedia.entries.map((entry) => 
                _buildInfoItem(_getSocialMediaIcon(entry.key), entry.key, entry.value)
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context) {
    final shopsProvider = Provider.of<ShopsProvider>(context);
    final products = shopsProvider.products.where((p) => p.shopId == shop.id).toList();

    return products.isEmpty
        ? const Center(child: Text('لا توجد منتجات متاحة'))
        : ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(
                    product.imageUrls.isNotEmpty ? product.imageUrls.first : 'https://via.placeholder.com/60',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${product.price} جنيه'),
                      if (product.originalPrice > product.price)
                        Text(
                          '${product.originalPrice} جنيه',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // الانتقال لصفحة المنتج
                  },
                ),
              );
            },
          );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // متوسط التقييم
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '${shop.rating}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => 
                    Icon(
                      Icons.star,
                      color: index < shop.rating.floor() ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),
                Text('${shop.reviews} تقييم', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),

        // قائمة التقييمات
        ...List.generate(5, (index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('مستخدم ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: List.generate(5, (starIndex) => 
                              Icon(
                                Icons.star,
                                size: 16,
                                color: starIndex < 4 ? Colors.amber : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('منذ ${index + 1} أيام', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('تجربة رائعة والخدمة ممتازة. أنصح الجميع بالتجربة.'),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook': return Icons.facebook;
      case 'instagram': return Icons.camera_alt;
      case 'twitter': return Icons.tweet;
      default: return Icons.link;
    }
  }
}