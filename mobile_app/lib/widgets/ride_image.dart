import 'package:flutter/material.dart';

class RideImage extends StatelessWidget {
  const RideImage({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  bool get _isAsset => imagePath.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFEFE7), Color(0xFFEAFBFF)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.black45),
      ),
    );

    final image = _isAsset
        ? Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => fallback,
          )
        : Image.network(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => fallback,
          );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }
}
