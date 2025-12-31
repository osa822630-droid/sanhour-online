import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _adminStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminStats();
  }

  Future<void> _loadAdminStats() async {
    try {
      final stats = await ApiService.getAdminStats();
      setState(() {
        _adminStats = stats;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // إحصائيات سريعة
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.3,
                      children: [
                        _buildAdminStat('المحلات', '${_adminStats?['totalShops']}', Colors.blue, Icons.store),
                        _buildAdminStat('المستخدمين', '${_adminStats?['totalUsers']}', Colors.green, Icons.people),
                        _buildAdminStat('الطلبات', '${_adminStats?['totalOrders']}', Colors.orange, Icons.shopping_cart),
                        _buildAdminStat('العروض', '${_adminStats?['activeOffers']}', Colors.purple, Icons.local_offer),
                      ],
                    ),
                  ),

                  // الإيرادات الإجمالية
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.attach_money, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'الإيرادات الإجمالية',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_adminStats?['totalRevenue']} جنيه',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(
                            value: 0.65,
                            backgroundColor: Colors.grey,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                            const SizedBox(height: 4),
                          const Text(
                            '65% من الهدف الشهري',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // إدارة المحلات
                  _buildManagementSection(
                    'إدارة المحلات',
                    Icons.store,
                    Colors.blue,
                    [
                      _buildManagementItem('عرض جميع المحلات', '${_adminStats?['totalShops']} محل', Icons.list, () {}),
                      _buildManagementItem('المحلات المعلقة', '${_adminStats?['pendingApprovals']} قيد المراجعة', Icons.pending, () {}),
                      _buildManagementItem('إضافة محل جديد', 'تسجيل يدوي', Icons.add_business, () {}),
                      _buildManagementItem('المحلات المميزة', 'عرض المميزين', Icons.star, () {}),
                    ],
                  ),

                  // إدارة المستخدمين
                  _buildManagementSection(
                    'إدارة المستخدمين',
                    Icons.people,
                    Colors.green,
                    [
                      _buildManagementItem('جميع المستخدمين', '${_adminStats?['totalUsers']} مستخدم', Icons.group, () {}),
                      _buildManagementItem('التجار', 'إدارة الحسابات', Icons.business_center, () {}),
                      _buildManagementItem('المشرفين', 'صلاحيات المدير', Icons.admin_panel_settings, () {}),
                      _buildManagementItem('حسابات مجمدة', 'مراجعة البلاغات', Icons.block, () {}),
                    ],
                  ),

                  // النظام والتصويت
                  _buildManagementSection(
                    'النظام والتصويت',
                    Icons.ballot,
                    Colors.orange,
                    [
                      _buildManagementItem('نتائج التصويت', 'الفائزون الشهريون', Icons.emoji_events, () {}),
                      _buildManagementItem('إعدادات النظام', 'تهيئة التطبيق', Icons.settings, () {}),
                      _buildManagementItem('التقارير', 'تقارير الأداء', Icons.analytics, () {}),
                      _buildManagementItem('الاشتراكات', 'إدارة الباقات', Icons.card_membership, () {}),
                    ],
                  ),

                  // الفئات الأكثر نشاطاً
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.category, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'الفئات الأكثر نشاطاً',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...(_adminStats?['topCategories'] ?? []).map<Widget>((category) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(category['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('${category['shops']} محل - ${category['revenue']} جنيه'),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    value: category['shops'] / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),

                  // الأنشطة الأخيرة
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.history, color: Colors.brown),
                              SizedBox(width: 8),
                              Text(
                                'آخر الأنشطة',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...(_adminStats?['recentActivities'] ?? []).map<Widget>((activity) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: const Icon(Icons.notifications, size: 20, color: Colors.blue),
                            ),
                            title: Text(activity['action']),
                            subtitle: Text('${activity['shop'] ?? activity['user']} - ${activity['time']}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),

                  // أدوات متقدمة
                  _buildManagementSection(
                    'أدوات متقدمة',
                    Icons.build,
                    Colors.brown,
                    [
                      _buildManagementItem('نسخ احتياطي', 'حفظ البيانات', Icons.backup, () {}),
                      _buildManagementItem('سجلات النظام', 'مراجعة السجلات', Icons.history, () {}),
                      _buildManagementItem('الكود التفعيلي', 'إنشاء أكواد', Icons.code, () {}),
                      _buildManagementItem('الصيانة', 'إعدادات الخادم', Icons.engineering, () {}),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildAdminStat(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(String title, IconData icon, Color color, List<Widget> items) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildManagementItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey[600]),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}