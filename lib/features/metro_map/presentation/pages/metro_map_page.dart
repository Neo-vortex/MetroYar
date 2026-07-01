import 'package:flutter/material.dart';

import '../widgets/map_controls.dart';
import '../widgets/map_legend.dart';
import '../widgets/zoomable_svg_viewer.dart';

class MetroMapPage extends StatefulWidget {
  const MetroMapPage({super.key});

  @override
  State<MetroMapPage> createState() => _MetroMapPageState();
}

class _MetroMapPageState extends State<MetroMapPage> {
  final GlobalKey<ZoomableSvgViewerState> _viewerKey =
      GlobalKey<ZoomableSvgViewerState>();
  bool _isFullscreen = false;
  bool _showLegend = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: const Text('نقشهٔ مترو تهران'),
              actions: [
                IconButton(
                  tooltip: _showLegend ? 'پنهان کردن راهنما' : 'نمایش راهنما',
                  icon: Icon(
                    _showLegend ? Icons.layers_rounded : Icons.layers_outlined,
                  ),
                  onPressed: () => setState(() => _showLegend = !_showLegend),
                ),
              ],
            ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              // Always a bright/white background here, regardless of the
              // app's theme (light or dark): the map SVG's text/labels are
              // drawn in black, so a dark surface would make them unreadable.
              child: ColoredBox(
                color: Colors.white,
                child: ZoomableSvgViewer(key: _viewerKey),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: _FullscreenToggle(
                  isFullscreen: _isFullscreen,
                  onPressed: () =>
                      setState(() => _isFullscreen = !_isFullscreen),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: MapControls(
                onZoomIn: () => _viewerKey.currentState?.zoomIn(),
                onZoomOut: () => _viewerKey.currentState?.zoomOut(),
                onReset: () => _viewerKey.currentState?.resetZoom(),
              ),
            ),
            if (_showLegend)
              Positioned(
                bottom: 16,
                right: 16,
                left: 86,
                child: const MapLegend(),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenToggle extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback onPressed;

  const _FullscreenToggle({required this.isFullscreen, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainer.withValues(alpha: 0.95),
      elevation: 4,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: isFullscreen ? 'خروج از تمام‌صفحه' : 'نمایش تمام‌صفحه',
        icon: Icon(
          isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
          color: colors.onSurface,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
