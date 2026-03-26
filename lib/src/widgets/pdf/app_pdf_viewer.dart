import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app_pdf_side_panel.dart';
import 'app_pdf_toolbar.dart';

enum AppPdfSourceType { network, file, asset, data }

/// A highly reusable and adaptive PDF Viewer widget powered by `pdfrx`.
/// Provides a desktop-friendly toolbar by default on larger screens, and a cleaner
/// touch-friendly layout on smaller screens (mobile).
class AppPdfViewer extends StatefulWidget {
  final AppPdfSourceType sourceType;

  /// The source link/path. Null if `sourceType` is data.
  final String? source;

  /// The raw bytes of the PDF. Null unless `sourceType` is data.
  final Uint8List? data;

  /// The title to display on the desktop toolbar (e.g., file name).
  final String? title;

  /// Callback triggered when the download action is pressed.
  final VoidCallback? onDownload;

  /// Callback triggered when the print action is pressed.
  final VoidCallback? onPrint;

  /// Whether to force hide the desktop toolbar even on large screens.
  final bool hideToolbar;

  const AppPdfViewer.network(
    String url, {
    super.key,
    this.title,
    this.onDownload,
    this.onPrint,
    this.hideToolbar = false,
  })  : sourceType = AppPdfSourceType.network,
        source = url,
        data = null;

  const AppPdfViewer.file(
    String path, {
    super.key,
    this.title,
    this.onDownload,
    this.onPrint,
    this.hideToolbar = false,
  })  : sourceType = AppPdfSourceType.file,
        source = path,
        data = null;

  const AppPdfViewer.asset(
    String assetPath, {
    super.key,
    this.title,
    this.onDownload,
    this.onPrint,
    this.hideToolbar = false,
  })  : sourceType = AppPdfSourceType.asset,
        source = assetPath,
        data = null;

  const AppPdfViewer.data(
    Uint8List this.data, {
    super.key,
    this.title,
    this.onDownload,
    this.onPrint,
    this.hideToolbar = false,
  })  : sourceType = AppPdfSourceType.data,
        source = null;

  @override
  State<AppPdfViewer> createState() => _AppPdfViewerState();
}

class _AppPdfViewerState extends State<AppPdfViewer> {
  late final PdfViewerController _pdfController;
  PdfTextSearcher? _searcher;
  int _currentPage = 0;
  int _pageCount = 0;
  double _currentZoom = 1.0;
  bool _showSidePanel = false;

  void _toggleSideMenu() {
    setState(() => _showSidePanel = !_showSidePanel);
  }

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _pdfController.addListener(_onPdfCtrlChanged);
  }

  void _onViewerReady(PdfDocument document, PdfViewerController controller) {
    if (mounted && _searcher == null) {
      _searcher = PdfTextSearcher(_pdfController);
      _searcher!.addListener(_onSearchChanged);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searcher?.dispose();
    _pdfController.removeListener(_onPdfCtrlChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  void _onPdfCtrlChanged() {
    if (!mounted) return;

    final page = _pdfController.pageNumber;
    final count = _pdfController.pages.length;
    final zoom = _pdfController.currentZoom;

    bool needsUpdate = false;
    if (_currentPage != page && page != null) {
      _currentPage = page;
      needsUpdate = true;
    }
    if (_pageCount != count) {
      _pageCount = count;
      needsUpdate = true;
    }
    if (_currentZoom != zoom) {
      _currentZoom = zoom;
      needsUpdate = true;
    }

    if (needsUpdate) {
      setState(() {});
    }
  }

  Widget _buildPdfCore() {
    final params = PdfViewerParams(
      // enableTextSelection: true,
      maxScale: 8.0,
      backgroundColor: Colors.grey.shade300,
      matchTextColor: Colors.yellow.withValues(alpha: 0.5),
      activeMatchTextColor: Colors.orange.withValues(alpha: 0.5),
      onViewerReady: _onViewerReady,
      pagePaintCallbacks: [
        if (_searcher != null) _searcher!.pageTextMatchPaintCallback,
      ],
    );

    switch (widget.sourceType) {
      case AppPdfSourceType.network:
        return PdfViewer.uri(
          Uri.parse(widget.source!),
          controller: _pdfController,
          params: params,
        );
      case AppPdfSourceType.file:
        return PdfViewer.file(
          widget.source!,
          controller: _pdfController,
          params: params,
        );
      case AppPdfSourceType.asset:
        return PdfViewer.asset(
          widget.source!,
          controller: _pdfController,
          params: params,
        );
      case AppPdfSourceType.data:
        return PdfViewer.data(
          widget.data!,
          sourceName: widget.title ?? 'Document',
          controller: _pdfController,
          params: params,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Evaluate toolbar visibility purely by configuration flag `hideToolbar`,
        // sidestepping internal parent width bounds that hide it under fractional Flex boxes.
        final showToolbar = !widget.hideToolbar;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showSidePanel && _searcher != null)
              AppPdfSidePanel(controller: _pdfController, searcher: _searcher!),
            // Sisa area kanan PDF viewer (Toolbar + Konten)
            Expanded(
              child: Column(
                children: [
                  if (showToolbar)
                    AppPdfToolbar(
                      title: widget.title ?? 'Document.pdf',
                      currentPage: _currentPage,
                      pageCount: _pageCount,
                      currentZoom: _currentZoom,
                      controller: _pdfController,
                      onMenuPressed: _toggleSideMenu,
                      onDownload: widget.onDownload,
                      onPrint: widget.onPrint,
                    ),
                  Expanded(
                    child: _buildPdfCore(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
