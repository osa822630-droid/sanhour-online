import 'package:flutter/material.dart';
import '../providers/shops_provider.dart';
import 'package:provider/provider.dart';
import '../screens/detail_screen.dart';

class SubCategoryList extends StatefulWidget {
  final String type;
  final String mainCategory;

  const SubCategoryList({
    super.key,
    required this.type,
    this.mainCategory = 'all',
  });

  @override
  State<SubCategoryList> createState() => _SubCategoryListState();
}

class _SubCategoryListState extends State<SubCategoryList>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final Map<String, List<String>> _subCategories = {
    'الكل': [],
    'مطاعم': ['وجبات سريعة', 'مطاعم عربية', 'مطاعم أجنبية', 'مأكولات بحرية'],
    'كافيهات': ['كافيهات عادية', 'كافيهات راقية', 'شيشة', 'إنترنت'],
    'حلويات': ['حلويات شرقية', 'حلويات غربية', 'كيك ومعجنات', 'آيس كريم'],
    'عصائر': ['عصائر طازجة', 'كوكتيل', 'سموذي', 'مشروبات ساخنة'],
    'سوبرماركت': ['بقالة', 'لحوم', 'خضروات', 'منتجات الألبان'],
    'فواكه وخضروات': ['فواكه', 'خضروات', 'موالح', 'موز'],
    'مخبوزات': ['خبز بلدي', 'معجنات', 'فطائر', 'كعك'],
    'عيادات': ['أسنان', 'باطنة', 'عيون', 'جلدية', 'أطفال'],
    'صيدليات': ['أدوية', 'مستحضرات تجميل', 'مستلزمات طبية'],
    'مدرسين': ['لغات', 'علوم', 'رياضيات', 'حاسب آلي'],
    'مكتبات': ['كتب', 'أدوات مدرسية', 'قرطاسية'],
    'رجالي': ['ملابس', 'أحذية', 'إكسسوارات', 'عطور'],
    'حريمي': ['ملابس', 'أحذية', 'حقائب', 'مكياج'],
    'أولادي': ['ملابس', 'ألعاب', 'مستلزمات أطفال'],
  };

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  void _initializeTabController() {
    // الحصول على الأقسام الفرعية المناسبة للنوع الرئيسي
    List<String> availableSubCategories = _getAvailableSubCategories();
    
    _tabController = TabController(
      length: availableSubCategories.length,
      vsync: this,
    );
  }

  List<String> _getAvailableSubCategories() {
    if (widget.mainCategory == 'all') {
      return _subCategories.keys.toList();
    }

    // فلترة الأقسام الفرعية بناءً على النوع الرئيسي
    switch (widget.mainCategory) {
      case 'مأكولات ومشروبات':
        return ['الكل', 'مطاعم', 'كافيهات', 'حلويات', 'عصائر'];
      case 'مواد غذائية':
        return ['الكل', 'سوبرماركت', 'فواكه وخضروات', 'مخبوزات'];
      case 'خدمات طبية':
        return ['الكل', 'عيادات', 'صيدليات'];
      case 'خدمات تعليمية':
        return ['الكل', 'مدرسين', 'مكتبات'];
      case 'ملابس':
        return ['الكل', 'رجالي', 'حريمي', 'أولادي'];
      case 'أثاث وأجهزة':
        return ['الكل', 'أجهزة كهربائية', 'موبيليا', 'مفروشات'];
      case 'خدمات المحمول':
        return ['الكل', 'سنترال', 'محلات', 'صيانة'];
      case 'وِرَش':
        return ['الكل', 'نجارة', 'حدادة', 'سمكرة'];
      case 'حِرَف':
        return ['الكل', 'كهربائي', 'سباك', 'نجار', 'حداد'];
      default:
        return ['الكل'];
    }
  }

  @override
  void didUpdateWidget(SubCategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mainCategory != widget.mainCategory ||
        oldWidget.type != widget.type) {
      _initializeTabController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final availableSubCategories = _getAvailableSubCategories();

    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: availableSubCategories.map((sub) {
              return Tab(
                text: sub,
                iconMargin: EdgeInsets.zero,
                height: 48,
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: availableSubCategories.map((subCategory) {
              return _buildSubCategoryContent(subCategory);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryContent(String subCategory) {
    return Consumer<ShopsProvider>(
      builder: (context, shopsProvider, child) {
        if (shopsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<dynamic> items = _getFilteredItems(shopsProvider, subCategory);

        if (items.isEmpty) {
          return _buildEmptyState(subCategory);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _refreshData(shopsProvider);
          },
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildListItem(context, item, shopsProvider);
            },
          ),
        );
      },
    );
  }

  List<dynamic> _getFilteredItems(ShopsProvider shopsProvider, String subCategory) {
    if (subCategory == 'الكل') {
      return _getAllItems(shopsProvider);
    }

    switch (widget.type) {
      case 'shops':
        return shopsProvider.shops.where((shop) {
          return _doesShopMatchSubCategory(shop, subCategory);
        }).toList();
      case 'products':
        return shopsProvider.products.where((product) {
          return _doesProductMatchSubCategory(product, subCategory);
        }).toList();
      case 'offers':
        return shopsProvider.offers.where((offer) {
          return _doesOfferMatchSubCategory(offer, shopsProvider, subCategory);
        }).toList();
      default:
        return [];
    }
  }

  List<dynamic> _getAllItems(ShopsProvider shopsProvider) {
    switch (widget.type) {
      case 'shops':
        return shopsProvider.shops;
      case 'products':
        return shopsProvider.products;
      case 'offers':
        return shopsProvider.offers;
      default:
        return [];
    }
  }

  bool _doesShopMatchSubCategory(Shop shop, String subCategory) {
    // منطق مطابقة المحل مع القسم الفرعي
    final categoryMap = {
      'مطاعم': ['مطعم', 'وجبات', 'طعام'],
      'كافيهات': ['كافيه', 'قهوة', 'شاي'],
      'حلويات': ['حلويات', 'حلواني', 'كيك'],
      'عصائر': ['عصائر', 'مشروبات'],
      'سوبرماركت': ['سوبرماركت', 'بقالة', 'ماركت'],
      // ... إضافة باقي المطابقات
    };

    final keywords = categoryMap[subCategory] ?? [subCategory];
    return keywords.any((keyword) =>
        shop.name.contains(keyword) || shop.category.contains(keyword));
  }

  bool _doesProductMatchSubCategory(Product product, String subCategory) {
    // منطق مطابقة المنتج مع القسم الفرعي
    final categoryMap = {
      'رجالي': ['رجالي', 'رجال', 'ذكر'],
      'حريمي': ['حريمي', 'نسائي', 'نساء', 'بنات'],
      'أولادي': ['أطفال', 'أولاد', 'بنات', 'طفل'],
      // ... إضافة باقي المطابقات
    };

    final keywords = categoryMap[subCategory] ?? [subCategory];
    return keywords.any((keyword) =>
        product.name.contains(keyword) || product.category.contains(keyword));
  }

  bool _doesOfferMatchSubCategory(
      Offer offer, ShopsProvider shopsProvider, String subCategory) {
    try {
      final shop = shopsProvider.shops.firstWhere(
        (s) => s.id == offer.shopId,
      );
      return _doesShopMatchSubCategory(shop, subCategory);
    } catch (e) {
      return false;
    }
  }

  Widget _buildEmptyState(String subCategory) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد ${_getTypeName()} في "$subCategory"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب قسم آخر أو غير كلمة البحث',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, dynamic item, ShopsProvider shopsProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildItemImage(item),
        title: _buildItemTitle(item),
        subtitle: _buildItemSubtitle(item),
        trailing: _buildItemTrailing(item, shopsProvider),
        onTap: () => _navigateToDetail(context, item),
      ),
    );
  }

  Widget _buildItemImage(dynamic item) {
    String imageUrl = '';
    if (item is Shop) {
      imageUrl = item.imageUrl;
    } else if (item is Product) {
      imageUrl = item.imageUrls.isNotEmpty ? item.imageUrls.first : '';
    } else if (item is Offer) {
      imageUrl = item.imageUrl;
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(imageUrl.isEmpty
          ? 'https://via.placeholder.com/50/CCCCCC/FFFFFF?text=صورة'
          : imageUrl),
      radius: 25,
    );
  }

  Widget _buildItemTitle(dynamic item) {
    String title = '';
    if (item is Shop) {
      title = item.name;
    } else if (item is Product) {
      title = item.name;
    } else if (item is Offer) {
      title = item.title;
    }

    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildItemSubtitle(dynamic item) {
    if (item is Shop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.category),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              Text('${item.rating}'),
              const SizedBox(width: 8),
              const Icon(Icons.visibility, size: 14, color: Colors.grey),
              Text('${item.views}'),
            ],
          ),
        ],
      );
    } else if (item is Product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${item.price} جنيه'),
          if (item.hasDiscount)
            Text(
              '${item.originalPrice} جنيه',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
        ],
      );
    } else if (item is Offer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('خصم ${item.discount}%'),
          Text(
            'ينتهي في ${_formatDate(item.validUntil)}',
            style: TextStyle(
              color: item.isAboutToExpire ? Colors.red : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildItemTrailing(dynamic item, ShopsProvider shopsProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFavoriteButton(item, shopsProvider),
        const SizedBox(height: 4),
        const Icon(Icons.arrow_forward_ios, size: 16),
      ],
    );
  }

  Widget _buildFavoriteButton(dynamic item, ShopsProvider shopsProvider) {
    bool isFavorite = false;
    String id = '';

    if (item is Shop) {
      isFavorite = item.isFavorite;
      id = item.id;
    } else if (item is Product) {
      isFavorite = item.isFavorite;
      id = item.id;
    } else if (item is Offer) {
      isFavorite = item.isFavorite;
      id = item.id;
    }

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
        size: 20,
      ),
      onPressed: () => _toggleFavorite(item, shopsProvider),
    );
  }

  void _toggleFavorite(dynamic item, ShopsProvider shopsProvider) {
    if (item is Shop) {
      shopsProvider.toggleShopFavorite(item.id);
    } else if (item is Product) {
      shopsProvider.toggleProductFavorite(item.id);
    } else if (item is Offer) {
      shopsProvider.toggleOfferFavorite(item.id);
    }
  }

  void _navigateToDetail(BuildContext context, dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(item: item),
      ),
    );
  }

  Future<void> _refreshData(ShopsProvider shopsProvider) async {
    switch (widget.type) {
      case 'shops':
        await shopsProvider.loadShops(refresh: true);
        break;
      case 'products':
        await shopsProvider.loadProducts(refresh: true);
        break;
      case 'offers':
        await shopsProvider.loadOffers(refresh: true);
        break;
    }
  }

  String _getTypeName() {
    switch (widget.type) {
      case 'shops':
        return 'محلات';
      case 'products':
        return 'منتجات';
      case 'offers':
        return 'عروض';
      default:
        return 'عناصر';
    }
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