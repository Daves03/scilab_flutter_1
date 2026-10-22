import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String? url;
  final String? assetPath;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.url,
    this.assetPath,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  static const double _minimumZoom = 1;
  static const double _maximumZoom = 6;
  static const double _zoomStep = 0.5;

  final PdfViewerController _controller = PdfViewerController();
  double _zoomLevel = _minimumZoom;
  double _initialZoomLevel = _minimumZoom;
  bool _configuredInitialZoom = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configuredInitialZoom) return;
    _configuredInitialZoom = true;
    _initialZoomLevel = MediaQuery.sizeOf(context).width < 600 ? 1.25 : 1;
    _zoomLevel = _initialZoomLevel;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setZoom(double value) {
    final zoom = value.clamp(_minimumZoom, _maximumZoom).toDouble();
    _controller.zoomLevel = zoom;
    setState(() => _zoomLevel = zoom);
  }

  void _onZoomChanged(PdfZoomDetails details) {
    if ((_zoomLevel - details.newZoomLevel).abs() < 0.01) return;
    setState(() => _zoomLevel = details.newZoomLevel);
  }

  Widget _buildPdfViewer() {
    final assetPath = widget.assetPath;
    if (assetPath != null && assetPath.isNotEmpty) {
      return SfPdfViewer.asset(
        assetPath,
        controller: _controller,
        initialZoomLevel: _initialZoomLevel,
        maxZoomLevel: _maximumZoom,
        interactionMode: PdfInteractionMode.pan,
        enableDoubleTapZooming: true,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        onZoomLevelChanged: _onZoomChanged,
      );
    }

    return SfPdfViewer.network(
      widget.url ?? '',
      controller: _controller,
      initialZoomLevel: _initialZoomLevel,
      maxZoomLevel: _maximumZoom,
      interactionMode: PdfInteractionMode.pan,
      enableDoubleTapZooming: true,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      onZoomLevelChanged: _onZoomChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildPdfViewer()),
          Positioned(
            right: 12,
            bottom: 16,
            child: Material(
              color: const Color(0xEE1E293B),
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Zoom out',
                    onPressed: _zoomLevel > _minimumZoom
                        ? () => _setZoom(_zoomLevel - _zoomStep)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                    color: Colors.white,
                    disabledColor: Colors.white38,
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${(_zoomLevel * 100).round()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Zoom in',
                    onPressed: _zoomLevel < _maximumZoom
                        ? () => _setZoom(_zoomLevel + _zoomStep)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                    color: Colors.white,
                    disabledColor: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
