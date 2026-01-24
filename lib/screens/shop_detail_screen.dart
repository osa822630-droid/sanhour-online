
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop.dart';
import '../providers/shops_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  void _launchURL(String? urlString) async {
    if (urlString != null && urlString.isNotEmpty) {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
         debugPrint('Could not launch $urlString');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shop.name),
          actions: [
            Consumer<ShopsProvider>(
              builder: (context, shopsProvider, child) {
                final isFavorite = shopsProvider.isFavorite(shop.id);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  tooltip: 'إضافة للمفضلة',
                  onPressed: () {
                    shopsProvider.toggleFavorite('shop', shop.id);
                  },
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'نظرة عامة'),
              Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'المنتجات'),
              Tab(icon: Icon(Icons.reviews_outlined), text: 'التقييمات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildProductsTab(context),
            _buildReviewsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تواصل معنا',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (shop.facebookUrl != null)
              _buildSocialIcon(FontAwesomeIcons.facebook, () => _launchURL(shop.facebookUrl), 'Facebook'),
            if (shop.instagramUrl != null)
              _buildSocialIcon(FontAwesomeIcons.instagram, () => _launchURL(shop.instagramUrl), 'Instagram'),
            if (shop.whatsapp != null)
              _buildSocialIcon(FontAwesomeIcons.whatsapp, () => _launchURL(shop.whatsapp), 'WhatsApp'),
            if (shop.tiktokUrl != null)
               _buildSocialIcon(FontAwesomeIcons.tiktok, () => _launchURL(shop.tiktokUrl), 'TikTok'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onPressed, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: FaIcon(icon, size: 30),
        onPressed: onPressed,
        color: Colors.grey[700],
      ),
    );
  }


  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              shop.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  shop.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                avatar: const Icon(Icons.star, color: Colors.amber, size: 18),
                label: Text(shop.rating.toStringAsFixed(1)),
                backgroundColor: Colors.amber.withAlpha(25), // Updated for deprecation
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${shop.category} • ${shop.location}',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
           const Text(
            'عن المحل',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            shop.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildSocialMediaButtons(context),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
           ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('رقم الهاتف'),
            subtitle: Text(shop.phone),
            onTap: () => _launchURL('tel:${shop.phone}'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text('يتم العمل على قسم المنتجات حالياً.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
     return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text('سيتم تفعيل التقييمات قريباً.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
