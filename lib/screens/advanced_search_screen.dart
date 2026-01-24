import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shops_provider.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/offer.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedCategory = 'كل الفئات';
  String _selectedPriceRange = 'كل الأسعار';
  String _selectedRating = 'كل التقييمات';
  String _selectedSort = 'الأكثر صلة';

  final List<String> _categories = [
    'كل الفئات',
    'مأكولات ومشروبات',
    'مواد غذائية',
    'خدمات طبية',
    'خدمات تعليمية',
    'ملابس',
    'أثاث وأجهزة',
    'خدمات المحمول',
    'وِرَش',
    'حِرَف',
  ];

  final List<String> _priceRanges = [
    'كل الأسعار',
    'اقتصادي (حتى 50 جنيه)',
    'متوسط (50 - 200 جنيه)',
    'فاخر (أكثر من 200 جنيه)',
  ];

  final List<String> _ratings = [
    'كل التقييمات',
    '4 نجوم فأكثر',
    '3 نجوم فأكثر',
    '2 نجوم فأكثر',
  ];

  final List<String> _sortOptions = [
    'الأكثر صلة',
    'الأعلى تقييماً',
    'الأكثر زيارة',
    'الأكثر إضافة للمفضلة',
    'الأحدث',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: const InputDecoration(
            hintText: 'ابحث عن محلات، منتجات، عروض...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: (value) {
            _performSearch(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'فلاتر البحث',
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              tooltip: 'مسح البحث',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المحلات'),
            Tab(text: 'المنتجات'),
            Tab(text: 'العروض'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchResults('shops'),
          _buildSearchResults('products'),
          _buildSearchResults('offers'),
        ],
      ),
    );
  }

  Widget _buildSearchResults(String type) {
    return Consumer<ShopsProvider>(
      builder: (context, shopsProvider, child) {
        List<dynamic> results = _getFilteredResults(shopsProvider, type);

        if (_searchController.text.isEmpty &&
            _selectedCategory == 'كل الفئات' &&
            _selectedPriceRange == 'كل الأسعار' &&
            _selectedRating == 'كل التقييمات') {
          return const Center(
            child: Text('استخدم شريط البحث أو الفلاتر للعثور على نتائج'),
          );
        }

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد نتائج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'جرب تغيير كلمات البحث أو الفلاتر',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            return _buildResultItem(results[index], type);
          },
        );
      },
    );
  }

  List<dynamic> _getFilteredResults(ShopsProvider shopsProvider, String type) {
    List<dynamic> allItems = [];

    switch (type) {
      case 'shops':
        allItems = shopsProvider.shops;
        break;
      case 'products':
        allItems = shopsProvider.products;
        break;
      case 'offers':
        allItems = shopsProvider.offers;
        break;
    }

    return allItems.where((item) {
      // فلترة بالنص
      if (_searchController.text.isNotEmpty) {
        final searchText = _searchController.text.toLowerCase();
        if (item is Shop) {
          if (!item.name.toLowerCase().contains(searchText) &&
              !item.category.toLowerCase().contains(searchText) &&
              !item.description.toLowerCase().contains(searchText)) {
            return false;
          }
        } else if (item is Product) {
          if (!item.name.toLowerCase().contains(searchText) &&
              !item.category.toLowerCase().contains(searchText) &&
              !item.description.toLowerCase().contains(searchText)) {
            return false;
          }
        } else if (item is Offer) {
          if (!item.title.toLowerCase().contains(searchText) &&
              !item.description.toLowerCase().contains(searchText)) {
            return false;
          }
        }
      }

      // فلترة بالفئة
      if (_selectedCategory != 'كل الفئات') {
        if (item is Shop) {
          if (item.category != _selectedCategory) return false;
        } else if (item is Product) {
          if (item.category != _selectedCategory) return false;
        }
      }

      // فلترة بالتقييم
      if (_selectedRating != 'كل التقييمات') {
        final minRating = _selectedRating == '4 نجوم فأكثر'
            ? 4.0
            : _selectedRating == '3 نجوم فأكثر'
                ? 3.0
                : 2.0;

        if (item is Shop) {
          if (item.rating < minRating) return false;
        } else if (item is Product) {
          if (item.rating < minRating) return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildResultItem(dynamic item, String type) {
    if (item is Shop) {
      return _buildShopItem(item);
    } else if (item is Product) {
      return _buildProductItem(item);
    } else if (item is Offer) {
      return _buildOfferItem(item);
    }

    return const SizedBox();
  }

  Widget _buildShopItem(Shop shop) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(shop.imageUrl),
          radius: 25,
        ),
        title: Text(shop.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shop.category),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text('${shop.rating}'),
                const SizedBox(width: 8),
                const Icon(Icons.visibility, size: 16, color: Colors.grey),
                Text('${shop.views}'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // الانتقال لصفحة المحل
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Image.network(
          product.imageUrls.isNotEmpty
              ? product.imageUrls.first
              : 'https://via.placeholder.com/50',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.price} جنيه'),
            if (product.hasPriceDrop)
              Text(
                '${product.oldPrice} جنيه',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text('${product.rating}'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // الانتقال لصفحة المنتج
        },
      ),
    );
  }

  Widget _buildOfferItem(Offer offer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Image.network(offer.imageUrl,
            width: 50, height: 50, fit: BoxFit.cover),
        title: Text(offer.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('خصم ${offer.discount}%'),
            Text(
              'ينتهي في ${_formatDate(offer.validUntil)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // الانتقال لصفحة العرض
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const Text(
              'فلاتر البحث',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildFilterSection('الفئة', _categories, _selectedCategory,
                      (value) {
                    setState(() => _selectedCategory = value);
                  }),
                  _buildFilterSection(
                      'نطاق السعر', _priceRanges, _selectedPriceRange, (value) {
                    setState(() => _selectedPriceRange = value);
                  }),
                  _buildFilterSection('التقييم', _ratings, _selectedRating,
                      (value) {
                    setState(() => _selectedRating = value);
                  }),
                  _buildFilterSection('ترتيب حسب', _sortOptions, _selectedSort,
                      (value) {
                    setState(() => _selectedSort = value);
                  }),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'كل الفئات';
                        _selectedPriceRange = 'كل الأسعار';
                        _selectedRating = 'كل التقييمات';
                        _selectedSort = 'الأكثر صلة';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('إعادة تعيين'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch(_searchController.text);
                    },
                    child: const Text('تطبيق الفلاتر'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options,
      String selectedValue, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    selected: selectedValue == option,
                    onSelected: (selected) {
                      if (selected) {
                        onSelected(option);
                      }
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _performSearch(String query) {
    // سيتم تحديث النتائج تلقائياً عبر Consumer
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'غداً';
    } else if (difference.inDays < 7) {
      return 'بعد ${difference.inDays} أيام';
    } else {
      return 'بعد ${difference.inDays ~/ 7} أسابيع';
    }
  }
}
