import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class AppImageViewer extends StatelessWidget {
  final String? imageSource;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const AppImageViewer({
    super.key,
    required this.imageSource,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource == null || imageSource!.trim().isEmpty) {
      return _buildFallback();
    }

    final src = imageSource!.trim();
    Widget imageWidget;

    try {
      if (src.startsWith('data:image')) {
        // Base64 encoded image
        final commaIndex = src.indexOf(',');
        final base64Str = commaIndex != -1 ? src.substring(commaIndex + 1) : src;
        final Uint8List bytes = base64Decode(base64Str);
        imageWidget = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } else if (src.startsWith('http://') || src.startsWith('https://')) {
        // Remote URL
        imageWidget = Image.network(
          src,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } else {
        // Local Asset
        imageWidget = Image.asset(
          src,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    } catch (_) {
      imageWidget = _buildFallback();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildFallback() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: borderRadius,
          ),
          child: const Center(
            child: Icon(Icons.image_rounded, color: Colors.grey, size: 28),
          ),
        );
  }
}
