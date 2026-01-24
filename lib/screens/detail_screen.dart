 // lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/shop.dart';
import '../models/offer.dart';
import '../providers/shops_provider.dart';

class DetailScreen extends StatelessWidget {
  final dynamic item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item is Product) {
      return _buildProductDetail(context, item as Product);
    } else if (item is Shop) {
      return _buildShopDetail(context, item as Shop);
    } else if (item is Offer) {
      return _buildOfferDetail(context, item as Offer);
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل')),
        body: const Center(child: Text('نوع العنصر غير مدعوم')),
      );
    }
  }

  Widget _buildProductDetail(BuildContext context, Product product) {
    final shopsProvider = Provider.of<ShopsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: product.isFavorite ? Colors.red : null,
            ),
            onPressed: () => shopsProvider.toggleProductFavorite(product.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(product.imageUrls),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceSection(product),
                  const SizedBox(height: 16),
                  _buildProductDetails(product),
                  const SizedBox(height: 16),
                  _buildRatingSection(product),
                  const SizedBox(height: 16),
                  _buildReviewsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildProductBottomBar(context, product),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.grey),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: imageUrls.map((url) {
        return Container(
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${product.price} جنيه',
          style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${product.originalPrice} جنيه',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product.discountPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProductDetails(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الوصف:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        if (product.colors.isNotEmpty) ...[
          const Text(
            'الألوان المتوفرة:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: product.colors.map((color) => Chip(
              label: Text(color),
              backgroundColor: _getColorFromName(color),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (product.sizes.isNotEmpty) ...[
          const Text(
            'المقاسات المتوفرة:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: product.sizes.map((size) => Chip(label: Text(size))).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (product.material.isNotEmpty) ...[
          const Text(
            'الخامة:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(product.material),
        ],
      ],
    );
  }

  Widget _buildRatingSection(Product product) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 4),
        Text('${product.rating}'),
        const SizedBox(width: 8),
        Text('(${product.reviews} تقييم)'),
        const Spacer(),
        const Text('عرض جميع التقييمات'),
        const Icon(Icons.arrow_forward_ios, size: 16),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تقييمات المستخدمين:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                ),
                title: Text('مستخدم ${index + 1}'),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Icon(Icons.star, size: 16, color: Colors.grey),
                      ],
                    ),
                    Text('تجربة رائعة والمنتج ممتاز. أنصح الجميع بالشراء.'),
                  ],
                ),
                trailing: Text('منذ ${index + 1} أيام', style: const TextStyle(fontSize: 12)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductBottomBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text('إضافة إلى السلة'),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopDetail(BuildContext context, Shop shop) {
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
            _buildShopOverview(shop),
            _buildShopProducts(context, shop),
            _buildShopReviews(shop),
          ],
        ),
      ),
    );
  }

  Widget _buildShopOverview(Shop shop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text('${shop.reviews} تقييم', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Text(
            shop.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildShopInfoSection(shop),
        ],
      ),
    );
  }

  Widget _buildShopInfoSection(Shop shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات المتجر',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoItem(Icons.phone, 'الهاتف', shop.phone),
        _buildInfoItem(Icons.location_on, 'الموقع', shop.location),
        _buildInfoItem(Icons.access_time, 'أوقات العمل', shop.workingHours),
        _buildInfoItem(Icons.calendar_today, 'أيام العمل', shop.workingDays.join('، ')),
        if (shop.socialMedia.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'وسائل التواصل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: shop.socialMedia.entries.map((entry) => 
              ActionChip(
                avatar: Icon(_getSocialMediaIcon(entry.key)),
                label: Text(entry.key),
                onPressed: () {},
              )
            ).toList(),
          ),
        ],
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

  Widget _buildShopProducts(BuildContext context, Shop shop) {
    final shopsProvider = Provider.of<ShopsProvider>(context);
    final products = shopsProvider.products.where((p) => p.shopId == shop.id).toList();

    if (products.isEmpty) {
      return const Center(child: Text('لا توجد منتجات متاحة'));
    }

    return ListView.builder(
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(item: product),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShopReviews(Shop shop) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
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
                          Text('مستخدم ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildOfferDetail(BuildContext context, Offer offer) {
    final shopsProvider = Provider.of<ShopsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(offer.title),
        actions: [
          IconButton(
            icon: Icon(
              offer.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: offer.isFavorite ? Colors.red : null,
            ),
            onPressed: () => shopsProvider.toggleOfferFavorite(offer.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(offer.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'خصم ${offer.discount}%',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offer.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _buildOfferDetails(offer),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildOfferBottomBar(context),
    );
  }

  Widget _buildOfferDetails(Offer offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل العرض:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDetailItem('ينتهي في', _formatOfferDate(offer.validUntil)),
        _buildDetailItem('الحالة', offer.isActive ? 'نشط' : 'منتهي'),
        _buildDetailItem('المشاهدات', '${offer.views}'),
        if (offer.isAboutToExpire)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            // 👇 تم التعديل: تم وضع const قبل Row بدلاً من القائمة
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text(
                  'هذا العرض ينتهي قريباً',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildOfferBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'استخدم العرض',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'أحمر':
        return Colors.red;
      case 'أزرق':
        return Colors.blue;
      case 'أخضر':
        return Colors.green;
      case 'أسود':
        return Colors.black;
      case 'أبيض':
        return Colors.white;
      case 'أصفر':
        return Colors.yellow;
      case 'برتقالي':
        return Colors.orange;
      case 'بنفسجي':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.chat;
      case 'whatsapp':
        return Icons.chat_bubble;
      default:
        return Icons.link;
    }
  }

  String _formatOfferDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'ينتهي اليوم';
    } else if (difference.inDays == 1) {
      return 'ينتهي غداً';
    } else if (difference.inDays < 7) {
      return 'ينتهي بعد ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'ينتهي بعد ${difference.inDays ~/ 7} أسابيع';
    } else {
      return 'ينتهي بعد ${difference.inDays ~/ 30} أشهر';
    }
  }
}
