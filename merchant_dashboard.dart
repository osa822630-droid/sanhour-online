import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shops_provider.dart';
import '../services/api_service.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  Map<String, dynamic>? _merchantStats;
  bool _isLoading = true;
  String _timeFrame = 'يومي'; // يومي، أسبوعي، شهري

  @override
  void initState() {
    super.initState();
    _loadMerchantStats();
  }

  Future<void> _loadMerchantStats() async {
    try {
      final stats = await ApiService.getMerchantStats('merchant_123');
      setState(() {
        _merchantStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopsProvider = Provider.of<ShopsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المتجر'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _timeFrame = value;
              });
              _loadMerchantStats();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'يومي', child: Text('عرض يومي')),
              const PopupMenuItem(value: 'أسبوعي', child: Text('عرض أسبوعي')),
              const PopupMenuItem(value: 'شهري', child: Text('عرض شهري')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // الإحصائيات السريعة
                _buildStatsOverview(),

                // الرسوم البيانية
                _buildChartsSection(),

                // مقارنة الأداء
                _buildPerformanceComparison(),

                // ترتيب المحل
                _buildShopRanking(),

                // المنتجات والعروض الأكثر أداءً
                _buildTopPerformers(),

                // الإجراءات السريعة
                _buildQuickActions(),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildStatsOverview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.3,
        children: [
          _buildStatCard(
            'إجمالي الزيارات',
            '${_merchantStats?['totalViews']}',
            Icons.remove_red_eye,
            Colors.blue,
            '${_merchantStats?['viewsChange']}% عن $_timeFrame الماضي',
          ),
          _buildStatCard(
            'الزوار الفريدون',
            '${_merchantStats?['uniqueVisitors']}',
            Icons.people,
            Colors.green,
            '${_merchantStats?['visitorsChange']}% عن $_timeFrame الماضي',
          ),
          _buildStatCard(
            'الإضافات للمفضلة',
            '${_merchantStats?['totalFavorites']}',
            Icons.favorite,
            Colors.red,
            '${_merchantStats?['favoritesChange']}% عن $_timeFrame الماضي',
          ),
          _buildStatCard(
            'التقييم العام',
            '${_merchantStats?['rating']}',
            Icons.star,
            Colors.amber,
            '${_merchantStats?['ratingChange']}% عن $_timeFrame الماضي',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    final isPositive = subtitle.contains('+');
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تحليلات الأداء',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // رسم بياني لعدد الزيارات
            _buildChartItem(
              'عدد الزيارات',
              Icons.timeline,
              Colors.blue,
              _merchantStats?['viewsData'] ?? [],
            ),
            const SizedBox(height: 16),
            // رسم بياني للإضافات للمفضلة
            _buildChartItem(
              'الإضافات للمفضلة',
              Icons.favorite,
              Colors.red,
              _merchantStats?['favoritesData'] ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartItem(String title, IconData icon, Color color, List<dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'رسم بياني لـ $title',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceComparison() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مقارنة الأداء',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComparisonItem('الزيارات', 
                _merchantStats?['currentViews'] ?? 0, 
                _merchantStats?['previousViews'] ?? 0),
            _buildComparisonItem('الإضافات للمفضلة', 
                _merchantStats?['currentFavorites'] ?? 0, 
                _merchantStats?['previousFavorites'] ?? 0),
            _buildComparisonItem('التقييمات', 
                _merchantStats?['currentReviews'] ?? 0, 
                _merchantStats?['previousReviews'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String title, int current, int previous) {
    final difference = current - previous;
    final percentage = previous > 0 ? (difference / previous * 100) : 0;
    final isPositive = difference >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            '$current',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopRanking() {
    final rank = _merchantStats?['shopRank'] ?? 0;
    final totalShops = _merchantStats?['totalShopsInCategory'] ?? 0;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ترتيب المتجر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'المركز $rank',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'من أصل $totalShops متجر في نفس القسم',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: rank / totalShops,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Column(
      children: [
        // المنتجات الأكثر أداءً
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المنتجات الأكثر أداءً',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...(_merchantStats?['topProducts'] ?? []).map<Widget>((product) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: const Icon(Icons.shopping_bag, color: Colors.green),
                  ),
                  title: Text(product['name']),
                  subtitle: Text('${product['views']} مشاهدة - ${product['favorites']} مفضلة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                )).toList(),
              ],
            ),
          ),
        ),

        // العروض الأكثر أداءً
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'العروض الأكثر أداءً',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...(_merchantStats?['topOffers'] ?? []).map<Widget>((offer) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: const Icon(Icons.local_offer, color: Colors.orange),
                  ),
                  title: Text(offer['title']),
                  subtitle: Text('${offer['views']} مشاهدة - ${offer['favorites']} مفضلة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                )).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإجراءات السريعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: [
                _buildActionItem('إضافة منتج', Icons.add, Colors.green, () {}),
                _buildActionItem('إنشاء عرض', Icons.local_offer, Colors.orange, () {}),
                _buildActionItem('رفع ملف Excel', Icons.upload_file, Colors.blue, () {}),
                _buildActionItem('تحليل متقدم', Icons.analytics, Colors.purple, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}