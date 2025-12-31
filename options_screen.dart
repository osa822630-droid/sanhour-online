import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'merchant_dashboard.dart';
import 'admin_dashboard.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('خيارات'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // حالة المستخدم
          _buildUserStatusSection(context, authProvider),

          // المظهر
          _buildSectionTitle('المظهر'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwitchListTile(
              title: const Text('الوضع الليلي'),
              secondary: const Icon(Icons.nightlight_round),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => themeProvider.toggleTheme(),
            ),
          ),

          // الحساب
          _buildSectionTitle('الحساب'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (!authProvider.isLoggedIn && !authProvider.isGuest) ...[
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.blue),
                    title: const Text('تسجيل الدخول'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showLoginDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.green),
                    title: const Text('إنشاء حساب جديد'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRegisterDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.orange),
                    title: const Text('الدخول كضيف'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => authProvider.loginAsGuest(),
                  ),
                ],

                if (authProvider.isLoggedIn || authProvider.isGuest) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    title: Text(authProvider.isGuest ? 'ضيف' : authProvider.userData?['name'] ?? ''),
                    subtitle: authProvider.isGuest 
                        ? const Text('تجربة التطبيق كضيف')
                        : Text(authProvider.userData?['email'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(height: 1),
                  if (authProvider.isLoggedIn)
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
                      onTap: () => _showLogoutConfirmation(context, authProvider),
                    ),
                ],
              ],
            ),
          ),

          // لوحات التحكم
          if (authProvider.isMerchant || authProvider.isAdmin) 
            _buildSectionTitle('لوحات التحكم'),

          if (authProvider.isMerchant)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.store, color: Colors.green),
                title: const Text('لوحة تحكم المتجر'),
                subtitle: const Text('إدارة منتجاتك وعروضك وإحصائياتك'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MerchantDashboard()),
                ),
              ),
            ),

          if (authProvider.isAdmin)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                title: const Text('لوحة الإدارة'),
                subtitle: const Text('إدارة المحلات والمستخدمين والنظام'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboard()),
                ),
              ),
            ),

          // الدعم
          _buildSectionTitle('الدعم'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.orange),
                  title: const Text('الأسئلة الشائعة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.contact_support, color: Colors.purple),
                  title: const Text('تواصل معنا'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.red),
                  title: const Text('الإبلاغ عن مشكلة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // معلومات التطبيق
          _buildSectionTitle('معلومات التطبيق'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info, color: Colors.blue),
                  title: Text('عن التطبيق'),
                  subtitle: Text('Sanhour Online - نسخة تجريبية'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.phone, color: Colors.green),
                  title: Text('اتصل بنا'),
                  subtitle: Text('+20 123 456 7890'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.email, color: Colors.orange),
                  title: Text('البريد الإلكتروني'),
                  subtitle: Text('support@sanhour.com'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.location_on, color: Colors.red),
                  title: Text('العنوان'),
                  subtitle: Text('سنهور، المنوفية، مصر'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserStatusSection(BuildContext context, AuthProvider authProvider) {
    Color statusColor = Colors.grey;
    String statusText = 'غير مسجل الدخول';
    IconData statusIcon = Icons.person_outline;

    if (authProvider.isGuest) {
      statusColor = Colors.orange;
      statusText = 'ضيف';
      statusIcon = Icons.person;
    } else if (authProvider.isLoggedIn) {
      if (authProvider.isAdmin) {
        statusColor = Colors.blue;
        statusText = 'مدير النظام';
        statusIcon = Icons.admin_panel_settings;
      } else if (authProvider.isMerchant) {
        statusColor = Colors.green;
        statusText = 'تاجر';
        statusIcon = Icons.store;
      } else {
        statusColor = Colors.purple;
        statusText = 'عميل';
        statusIcon = Icons.person;
      }
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (authProvider.isLoggedIn && authProvider.userData != null)
                    Text(
                      authProvider.userData!['name'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  if (authProvider.isLoggedIn && authProvider.userData != null)
                    Text(
                      authProvider.userData!['email'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('جرب الحسابات التجريبية:'),
              const SizedBox(height: 10),
              _buildTestAccountInfo('مدير النظام', 'admin@example.com', 'password123'),
              _buildTestAccountInfo('تاجر', 'merchant@example.com', 'password123'),
              _buildTestAccountInfo('عميل', 'customer@example.com', 'password123'),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await authProvider.login(emailController.text, passwordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم تسجيل الدخول بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في تسجيل الدخول: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestAccountInfo(String role, String email, String password) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('البريد: $email'),
            Text('كلمة المرور: $password'),
          ],
        ),
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء حساب جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'الاسم الكامل')),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني')),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'رقم الهاتف')),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'تأكيد كلمة المرور'), obscureText: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('نوع الحساب:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('عميل'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('تاجر'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنشاء الحساب بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('إنشاء حساب'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل الخروج بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}