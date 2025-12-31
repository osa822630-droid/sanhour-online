import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showShimmerEffect;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholder,
    this.errorWidget,
    this.showShimmerEffect = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => 
            placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => 
            errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    if (!showShimmerEffect) {
      return Container(
        color: Colors.grey[200],
        width: width,
        height: height,
      );
    }

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ?? Colors.grey[300]!,
      highlightColor: shimmerHighlightColor ?? Colors.grey[100]!,
      child: Container(
        color: Colors.white,
        width: width,
        height: height,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: _getErrorIconSize(),
            color: Colors.grey[400],
          ),
          if (height != null && height! > 60) ...[
            const SizedBox(height: 8),
            Text(
              'تعذر تحميل الصورة',
              style: TextStyle(
                fontSize: _getErrorTextSize(),
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _getErrorIconSize() {
    if (width != null && height != null) {
      return (width! + height!) / 8;
    }
    return 40.0;
  }

  double _getErrorTextSize() {
    if (width != null && height != null) {
      return (width! + height!) / 40;
    }
    return 12.0;
  }
}

class CachedCircleImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedCircleImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: fit,
        borderRadius: BorderRadius.circular(size / 2),
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}

class CachedNetworkImageWithProgress extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedNetworkImageWithProgress({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<CachedNetworkImageWithProgress> createState() => 
      _CachedNetworkImageWithProgressState();
}

class _CachedNetworkImageWithProgressState 
    extends State<CachedNetworkImageWithProgress> {
  double _progress = 0.0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedImage(
          imageUrl: widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          borderRadius: widget.borderRadius,
          placeholder: widget.placeholder,
          errorWidget: widget.errorWidget,
        ),
        if (_isLoading && _progress < 1.0)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  value: _progress,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}