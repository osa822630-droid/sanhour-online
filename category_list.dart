import 'package:flutter/material.dart';
import '../screens/category_home_screen.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  final Map<String, Map<String, dynamic>> categories = {
    'مأكولات ومشروبات': {
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'subcategories': ['مطاعم', 'كافيهات', 'حلويات', 'عصائر', 'سندوتشات']
    },
    'مواد غذائية': {
      'icon': Icons.shopping_basket,
      'color': Colors.green,
      'subcategories': ['سوبرماركت', 'فواكه وخضروات', 'مخبوزات', 'عطارة', 'جزارة']
    },
    'خدمات طبية': {
      'icon': Icons.local_hospital,
      'color': Colors.red,
      'subcategories': ['عيادات', 'معامل', 'صيدليات', 'مراكز طبية']
    },
    'خدمات تعليمية': {
      'icon': Icons.school,
      'color': Colors.blue,
      'subcategories': ['مدرسين', 'مكتبات', 'مطبعات', 'سناتر دروس', 'حضانات']
    },
    'ملابس': {
      'icon': Icons.checkroom,
      'color': Colors.purple,
      'subcategories': ['رجالي', 'حريمي', 'أولادي', 'شنط وأحذية', 'أقمشة']
    },
    'أثاث وأجهزة': {
      'icon': Icons.chair,
      'color': Colors.brown,
      'subcategories': ['أجهزة كهربائية', 'موبيليا', 'مفروشات', 'أدوات منزلية']
    },
    'خدمات المحمول': {
      'icon': Icons.phone_android,
      'color': Colors.teal,
      'subcategories': ['سنترال', 'محلات', 'صيانة', 'إكسسوارات']
    },
    'وِرَش': {
      'icon': Icons.build,
      'color': Colors.blueGrey,
      'subcategories': ['نجارة', 'حدادة', 'سمكرة', 'كهرباء سيارات']
    },
    'حِرَف': {
      'icon': Icons.handyman,
      'color': Colors.deepOrange,
      'subcategories': ['كهربائي', 'سباك', 'نجار', 'حداد', 'دِش', 'ترزي']
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'الأقسام',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryKey = categories.keys.elementAt(index);
                final category = categories[categoryKey]!;
                final icon = category['icon'] as IconData;
                final color = category['color'] as Color;
                final subcategories = category['subcategories'] as List<String>;

                return _buildCategoryItem(
                  context,
                  categoryKey,
                  icon,
                  color,
                  subcategories.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String categoryName,
    IconData icon,
    Color color,
    int subcategoryCount,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _navigateToCategory(context, categoryName);
          },
          onLongPress: () {
            _showCategoryInfo(context, categoryName, subcategoryCount);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$subcategoryCount',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryHomeScreen(category: categoryName),
      ),
    );
  }

  void _showCategoryInfo(BuildContext context, String categoryName, int subcategoryCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoryName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('عدد الأقسام الفرعية: $subcategoryCount'),
            const SizedBox(height: 8),
            const Text(
              'انقر فوق القسم للتصفح، أو اضغط مطولاً لمزيد من المعلومات.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}