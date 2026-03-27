import 'dart:typed_data';
import 'package:design_system/design_system.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfExamplePage extends StatefulWidget {
  const PdfExamplePage({super.key});

  @override
  State<PdfExamplePage> createState() => _PdfExamplePageState();
}

class _PdfExamplePageState extends State<PdfExamplePage> {
  Uint8List? _pdfBytes;
  String _fileName = '';
  String _fileSize = '';
  bool _isDragging = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      if (result.files.single.size > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Ukuran file maksimal 10 MB')));
        }
        return;
      }

      setState(() {
        _pdfBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
        _fileSize = _formatBytes(result.files.single.size);
      });
    }
  }

  Future<void> _handleDrop(DropDoneDetails details) async {
    if (details.files.isNotEmpty) {
      final file = details.files.first;
      if (file.name.toLowerCase().endsWith('.pdf')) {
        final bytes = await file.readAsBytes();

        if (bytes.length > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Ukuran file maksimal 10 MB')));
          }
          return;
        }

        setState(() {
          _pdfBytes = bytes;
          _fileName = file.name;
          _fileSize = _formatBytes(bytes.length);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Hanya file PDF yang diperbolehkan')));
        }
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _removeFile() {
    setState(() {
      _pdfBytes = null;
      _fileName = '';
      _fileSize = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Naskah / Surat Perjalanan Dinas', style: TextStyle(fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PrimaryButton(
              label: 'Kirim Naskah',
              leadingIcon: const Icon(Icons.send, size: 16),
              size: ButtonSize.small,
              onPressed: _pdfBytes != null ? () {} : null,
            ),
          ),
        ],
      ),
      body: AppAdaptiveLayout(mobile: _buildMobileLayout(), desktop: _buildDesktopLayout()),
    );
  }

  Widget _buildDesktopLayout() {
    return DropTarget(
      onDragDone: _handleDrop,
      onDragEntered: (details) => setState(() => _isDragging = true),
      onDragExited: (details) => setState(() => _isDragging = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: Container(
              color: _isDragging ? Colors.blue.withValues(alpha: 0.05) : Colors.grey.shade100,
              child: _pdfBytes == null
                  ? Center(child: _buildUploadPlaceholderDesktop())
                  : AppPdfViewer.data(_pdfBytes!, title: _fileName, onDownload: () {}),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: _pdfBytes == null ? _buildRightPanelEmpty() : _buildRightPanelWithFileInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholderDesktop() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.picture_as_pdf, size: 64, color: Colors.blue),
          ),
          const SizedBox(height: 24),
          const Text(
            'Naskah yang anda upload akan ditampilkan pada area ini. Klik tombol "upload file" atau drop file pada side panel di samping',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pastikan lampiran sudah menempel dengan naskah utamanya sebagai satu file pdf.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Upload Naskah',
            leadingIcon: const Icon(Icons.upload, size: 20, color: Colors.white),
            onPressed: _pickFile,
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanelEmpty({bool isMobile = false}) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder_open, size: 48, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Drop file di sini atau Klik tombol "upload naskah" di bawah ini. (maksimal 10 MB)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Upload Naskah',
                leadingIcon: const Icon(Icons.upload, size: 20, color: Colors.white),
                onPressed: _pickFile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanelWithFileInfo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: AppTab(
            labels: const ['File', 'Registrasi'],
            style: AppTabStyle.flat,
            contentHeight: 300,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_fileSize  Completed',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _removeFile,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'Form Registrasi / Info File (Desktop View)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: AppTab(
            labels: const ['File', 'Registrasi'],
            style: AppTabStyle.flat,
            contentHeight: _pdfBytes == null ? 280 : 110,
            children: [
              if (_pdfBytes == null)
                _buildRightPanelEmpty(isMobile: true)
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_fileSize  Completed',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: _removeFile,
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'Form Registrasi / Info File (Mobile View)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _pdfBytes == null
              ? Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Text('Belum ada dokumen PDF', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : AppPdfViewer.data(_pdfBytes!, title: _fileName, hideToolbar: true),
        ),
      ],
    );
  }
}

