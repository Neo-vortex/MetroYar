import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/asset_paths.dart';

/// A smooth, modern SVG map viewer:
///  • pinch-to-zoom & pan, courtesy of [InteractiveViewer]
///  • double-tap to zoom in/out, centered exactly where the user tapped
///  • animated zoom in/out/reset controls (no instant snapping — every
///    zoom step eases via an [AnimationController])
///  • graceful loading & error states for the SVG asset
class ZoomableSvgViewer extends StatefulWidget {
  const ZoomableSvgViewer({super.key});

  @override
  State<ZoomableSvgViewer> createState() => ZoomableSvgViewerState();
}

class ZoomableSvgViewerState extends State<ZoomableSvgViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();

  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  );
  Animation<Matrix4>? _zoomAnimation;

  static const double _minScale = 0.6;
  static const double _maxScale = 6.0;

  double get _currentScale => _transformController.value.getMaxScaleOnAxis();

  @override
  void initState() {
    super.initState();
    _animController.addListener(() {
      final animation = _zoomAnimation;
      if (animation != null) {
        _transformController.value = animation.value;
      }
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _animateTo(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: AppDurations.curve));
    _animController.forward(from: 0);
  }

  void zoomIn() => _zoomBy(1.6);

  void zoomOut() => _zoomBy(1 / 1.6);

  void resetZoom() => _animateTo(Matrix4.identity());

  void _zoomBy(double factor) {
    final newScale = (_currentScale * factor).clamp(_minScale, _maxScale);
    final effectiveFactor = newScale / _currentScale;
    if (effectiveFactor == 1) return;

    // Zoom around the viewport's center so repeated taps feel stable.
    final renderBox = context.findRenderObject() as RenderBox?;
    final center = renderBox != null
        ? Offset(renderBox.size.width / 2, renderBox.size.height / 2)
        : Offset.zero;

    final target = _matrixZoomedAround(center, effectiveFactor);
    _animateTo(target);
  }

  Matrix4 _matrixZoomedAround(Offset focalPoint, double scaleFactor) {
    final matrix = _transformController.value.clone();
    matrix.translate(focalPoint.dx, focalPoint.dy);
    matrix.scale(scaleFactor);
    matrix.translate(-focalPoint.dx, -focalPoint.dy);
    return matrix;
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapLocalPosition = details.localPosition;
  }

  Offset _doubleTapLocalPosition = Offset.zero;

  void _handleDoubleTap() {
    final isZoomedIn = _currentScale > 1.4;
    if (isZoomedIn) {
      resetZoom();
    } else {
      final target = _matrixZoomedAround(_doubleTapLocalPosition, 2.4);
      _animateTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: _minScale,
        maxScale: _maxScale,
        boundaryMargin: const EdgeInsets.all(120),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SvgPicture.asset(
              AssetPaths.metroMapSvg,
              placeholderBuilder: (context) => const SizedBox(
                width: 48,
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2.6)),
              ),
              errorBuilder: (context, error, stackTrace) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'فایل نقشه (${AssetPaths.metroMapSvg}) یافت نشد.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
