import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ZoomableSvgPage extends StatefulWidget {
  final String svgAssetPath;

  const ZoomableSvgPage({
    Key? key,
    required this.svgAssetPath,
  }) : super(key: key);

  @override
  State<ZoomableSvgPage> createState() => _ZoomableSvgPageState();
}

class _ZoomableSvgPageState extends State<ZoomableSvgPage> {
  final TransformationController _transformationController =
  TransformationController();
  String? _errorMessage;
  String? _cleanedSvgString;

  @override
  void initState() {
    super.initState();
    _loadAndCleanSvg();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadAndCleanSvg() async {
    try {
      // Load the SVG file as string
      String svgString = await rootBundle.loadString(widget.svgAssetPath);

      // Clean the SVG string to fix common parsing issues
      String cleaned = _cleanSvgString(svgString);

      setState(() {
        _cleanedSvgString = cleaned;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading SVG: $e';
      });
    }
  }

  String _cleanSvgString(String svgString) {
    // Remove extra spaces and fix number formatting issues
    String cleaned = svgString;

    // Fix multiple spaces between numbers
    cleaned = cleaned.replaceAllMapped(
        RegExp(r'(\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*)'),
            (match) => '${match.group(1)},${match.group(2)},${match.group(3)},${match.group(4)}'
    );

    // Fix spaces in path data
    cleaned = cleaned.replaceAllMapped(
        RegExp(r'd="([^"]*)"'),
            (match) {
          String pathData = match.group(1)!;
          // Add commas between consecutive numbers
          pathData = pathData.replaceAllMapped(
              RegExp(r'(\d+\.?\d*)\s+(\d+\.?\d*)'),
                  (m) => '${m.group(1)},${m.group(2)}'
          );
          return 'd="$pathData"';
        }
    );

    // Remove any malformed attributes that might cause parsing issues
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'="[^"]*[^\d\s,.-][^"]*"'), '');

    return cleaned;
  }

  void _resetTransform() {
    _transformationController.value = Matrix4.identity();
  }

  Widget _buildSvgWidget() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'SVG Loading Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: _loadAndCleanSvg,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cleanedSvgString == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SvgPicture.string(
      _cleanedSvgString!,
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(30.0),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoomable SVG Viewer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _resetTransform,
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Reset View',
          ),
          IconButton(
            onPressed: _loadAndCleanSvg,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload SVG',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100],
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.1,
          maxScale: 10.0,
          constrained: false,
          child: Container(
            padding: const EdgeInsets.all(50),
            child: Center(
              child: _buildSvgWidget(),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            onPressed: () {
              final Matrix4 matrix = Matrix4.copy(_transformationController.value);
              matrix.scale(1.2);
              _transformationController.value = matrix;
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: () {
              final Matrix4 matrix = Matrix4.copy(_transformationController.value);
              matrix.scale(0.8);
              _transformationController.value = matrix;
            },
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}

// Example usage in your main app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVG Viewer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ZoomableSvgPage(
        svgAssetPath: 'assets/images/your_svg_file.svg', // Replace with your SVG path
      ),
    );
  }
}

// Alternative: File-based SVG viewer for local files
class FileSvgViewer extends StatefulWidget {
  final String filePath;

  const FileSvgViewer({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  State<FileSvgViewer> createState() => _FileSvgViewerState();
}

class _FileSvgViewerState extends State<FileSvgViewer> {
  final TransformationController _transformationController =
  TransformationController();
  String? _svgContent;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSvgFile();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadSvgFile() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        String content = await file.readAsString();
        // Clean the SVG content
        content = _cleanSvgContent(content);
        setState(() {
          _svgContent = content;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'SVG file not found at: ${widget.filePath}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading SVG file: $e';
      });
    }
  }

  String _cleanSvgContent(String content) {
    // More comprehensive cleaning
    String cleaned = content;

    // Remove BOM if present
    if (cleaned.startsWith('\uFEFF')) {
      cleaned = cleaned.substring(1);
    }

    // Fix number sequences that might be malformed
    cleaned = cleaned.replaceAllMapped(
        RegExp(r'(\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*)'),
            (match) => '${match.group(1)} ${match.group(2)} ${match.group(3)} ${match.group(4)}'
    );

    // Fix coordinate lists in path data
    cleaned = cleaned.replaceAllMapped(
        RegExp(r'd="([^"]*)"'),
            (match) {
          String pathData = match.group(1)!;
          // Ensure proper spacing in path commands
          pathData = pathData.replaceAllMapped(
              RegExp(r'([MmLlHhVvCcSsQqTtAaZz])([0-9.-])'),
                  (m) => '${m.group(1)} ${m.group(2)}'
          );
          return 'd="$pathData"';
        }
    );

    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File SVG Viewer'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _transformationController.value = Matrix4.identity();
            },
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Reset View',
          ),
          IconButton(
            onPressed: _loadSvgFile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[50],
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.1,
          maxScale: 10.0,
          constrained: false,
          child: Container(
            padding: const EdgeInsets.all(50),
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSvgFile,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (_svgContent == null) {
      return const CircularProgressIndicator();
    }

    return SvgPicture.string(
      _svgContent!,
      fit: BoxFit.contain,
    );
  }
}

// Alternative implementation with more advanced gesture handling
class AdvancedZoomableSvgPage extends StatefulWidget {
  final String svgAssetPath;

  const AdvancedZoomableSvgPage({
    Key? key,
    required this.svgAssetPath,
  }) : super(key: key);

  @override
  State<AdvancedZoomableSvgPage> createState() => _AdvancedZoomableSvgPageState();
}

class _AdvancedZoomableSvgPageState extends State<AdvancedZoomableSvgPage> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced SVG Viewer'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _scale = 1.0;
                _offset = Offset.zero;
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black12,
        child: GestureDetector(
          onScaleStart: (details) {
            _previousScale = _scale;
            _previousOffset = _offset;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = _previousScale * details.scale;
              _scale = _scale.clamp(0.1, 5.0);

              _offset = _previousOffset + details.focalPointDelta;
            });
          },
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: SvgPicture.asset(
                  widget.svgAssetPath,
                  fit: BoxFit.contain,
                  width: 300,
                  height: 300,
                  placeholderBuilder: (BuildContext context) => Container(
                    width: 300,
                    height: 300,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _scale = (_scale * 1.2).clamp(0.1, 5.0);
                });
              },
              icon: const Icon(Icons.zoom_in),
              label: const Text('Zoom In'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _scale = (_scale * 0.8).clamp(0.1, 5.0);
                });
              },
              icon: const Icon(Icons.zoom_out),
              label: const Text('Zoom Out'),
            ),
          ],
        ),
      ),
    );
  }
}