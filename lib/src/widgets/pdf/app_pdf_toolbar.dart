import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Desktop toolbar equivalent for AppPdfViewer mimicking standard PDF readers.
class AppPdfToolbar extends StatelessWidget {
  const AppPdfToolbar({
    super.key,
    required this.title,
    required this.currentPage,
    required this.pageCount,
    required this.currentZoom,
    required this.controller,
    required this.onMenuPressed,
    this.onDownload,
    this.onPrint,
  });

  final String title;
  final int currentPage;
  final int pageCount;
  final double currentZoom;
  final PdfViewerController controller;
  final VoidCallback onMenuPressed;
  final VoidCallback? onDownload;
  final VoidCallback? onPrint;

  void _zoomIn() {
    controller.setZoom(
      controller.centerPosition,
      (currentZoom * 1.5).clamp(0.1, 8.0),
    );
  }

  void _zoomOut() {
    controller.setZoom(
      controller.centerPosition,
      (currentZoom / 1.5).clamp(0.1, 8.0),
    );
  }

  void _fitWidth() {
    controller.setZoom(controller.centerPosition, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    const divider = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: VerticalDivider(color: Colors.grey, width: 1),
    );

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF323639), // Standard Native Dark Grey
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 13),
        child: IconTheme(
          data: const IconThemeData(color: Colors.white, size: 20),
          child: Row(
            children: [
              // 1. Menu Icon
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onMenuPressed,
                splashRadius: 20,
              ),
              const SizedBox(width: 16),

              // 2. Title
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 3. Page Controls
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171A1C), // Deep contrast box
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('$currentPage'),
                    ),
                    const SizedBox(width: 8),
                    Text('/  $pageCount'),
                    
                    divider, // |
                    
                    // 4. Zoom Controls (Combined here visually)
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _zoomOut,
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171A1C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${(currentZoom * 100).toInt()}%'),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _zoomIn,
                      splashRadius: 20,
                    ),

                    divider, // |
                  ],
                ),
              ),

              // 5. Bounds & Actions
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fit_screen),
                      onPressed: _fitWidth,
                      tooltip: 'Fit screen',
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.rotate_right),
                      onPressed: () {}, // Optional rotate
                      tooltip: 'Rotate',
                      splashRadius: 20,
                    ),
                    const Spacer(),
                    if (onDownload != null)
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'Download',
                        onPressed: onDownload,
                        splashRadius: 20,
                      ),
                    if (onPrint != null)
                      IconButton(
                        icon: const Icon(Icons.print),
                        tooltip: 'Print',
                        onPressed: onPrint,
                        splashRadius: 20,
                      ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
