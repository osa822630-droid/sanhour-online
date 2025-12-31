import 'package:flutter/material.dart';

class PaginationWidget extends StatefulWidget {
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final String? noMoreText;
  final String? loadingText;
  final double loadingIndicatorSize;
  final Color loadingIndicatorColor;

  const PaginationWidget({
    super.key,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoading,
    this.noMoreText,
    this.loadingText,
    this.loadingIndicatorSize = 20.0,
    this.loadingIndicatorColor = Colors.blue,
  });

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!widget.hasMore || widget.isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore();
    } catch (e) {
      // يمكن إضافة معالجة الأخطاء هنا
      print('خطأ في تحميل المزيد: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoadingMore || widget.isLoading) _buildLoadingIndicator(),
        if (!widget.hasMore && !widget.isLoading) _buildNoMoreItems(),
        if (widget.hasMore && !_isLoadingMore && !widget.isLoading) _buildLoadMoreButton(),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: widget.loadingIndicatorSize,
            height: widget.loadingIndicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.loadingIndicatorColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.loadingText ?? 'جاري تحميل المزيد...',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreItems() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 24,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          Text(
            widget.noMoreText ?? 'تم عرض كل العناصر',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton.icon(
        onPressed: _loadMore,
        icon: const Icon(Icons.refresh),
        label: const Text('تحميل المزيد'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class PaginationListView extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final String? noMoreText;
  final String? loadingText;

  const PaginationListView({
    super.key,
    required this.children,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoading,
    this.controller,
    this.padding,
    this.noMoreText,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: children.length + 1,
      itemBuilder: (context, index) {
        if (index == children.length) {
          return PaginationWidget(
            onLoadMore: onLoadMore,
            hasMore: hasMore,
            isLoading: isLoading,
            noMoreText: noMoreText,
            loadingText: loadingText,
          );
        }
        return children[index];
      },
    );
  }
}

class PaginationGridView extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final SliverGridDelegate gridDelegate;
  final String? noMoreText;
  final String? loadingText;

  const PaginationGridView({
    super.key,
    required this.children,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoading,
    this.controller,
    this.padding,
    required this.gridDelegate,
    this.noMoreText,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => children[index],
              childCount: children.length,
            ),
            gridDelegate: gridDelegate,
          ),
        ),
        SliverToBoxAdapter(
          child: PaginationWidget(
            onLoadMore: onLoadMore,
            hasMore: hasMore,
            isLoading: isLoading,
            noMoreText: noMoreText,
            loadingText: loadingText,
          ),
        ),
      ],
    );
  }
}