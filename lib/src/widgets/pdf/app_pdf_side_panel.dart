import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class AppPdfSidePanel extends StatefulWidget {
  const AppPdfSidePanel({super.key, required this.controller, required this.searcher});
  final PdfViewerController controller;
  final PdfTextSearcher searcher;

  @override
  State<AppPdfSidePanel> createState() => _AppPdfSidePanelState();
}

class _AppPdfSidePanelState extends State<AppPdfSidePanel> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(icon: Icon(Icons.grid_view, size: 20), text: 'Thumbnails'),
              Tab(icon: Icon(Icons.format_list_bulleted, size: 20), text: 'Outline'),
              Tab(icon: Icon(Icons.search, size: 20), text: 'Search'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThumbnails(),
                _buildOutline(),
                _buildSearch(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnails() {
    final pageCount = widget.controller.pages.length;
    if (pageCount == 0) return const Center(child: Text('No pages available'));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Paper proportion A4 roughly
      ),
      itemCount: pageCount,
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        return InkWell(
          onTap: () => widget.controller.goToPage(pageNumber: pageNum),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    // Ideally we use PdfDocument.render or PdfPageImageProvider from pdfrx here
                    // Due to pdfrx engine abstraction, a placeholder mimicking the page represents it.
                    child: Icon(Icons.description_outlined, size: 40, color: Colors.grey.shade400),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '$pageNum',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutline() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Daftar isi (Outline/Bookmarks) dokumen akan diloloskan di sini menggunakan konektor data dari engine pdfrx Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search text in PDF...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.searcher.startTextSearch(
                  value,
                  caseInsensitive: true,
                  goToFirstMatch: true,
                );
              } else {
                widget.searcher.resetTextSearch();
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: widget.searcher,
              builder: (context, _) {
                final isSearching = widget.searcher.isSearching;
                final matchCount = widget.searcher.matches.length;
                final currentIdx =
                    widget.searcher.currentIndex != null ? widget.searcher.currentIndex! + 1 : 0;

                if (isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchController.text.isEmpty) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.manage_search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Type above and press enter to search.\nThis utilizes pdfrx native text search hooks.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  );
                }

                if (matchCount == 0) {
                  return const Center(
                    child: Text('No matches found.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$currentIdx of $matchCount matches'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_up),
                              onPressed: widget.searcher.goToPrevMatch,
                            ),
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onPressed: widget.searcher.goToNextMatch,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: matchCount,
                        itemBuilder: (context, index) {
                          final match = widget.searcher.matches[index];
                          final isSelected = widget.searcher.currentIndex == index;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                            title: Text('Page ${match.pageNumber}'),
                            onTap: () => widget.searcher.goToMatchOfIndex(index),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
