import 'dart:convert';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class PdfExamplePage extends StatelessWidget {
  const PdfExamplePage({super.key});

  // Base64 sample for a minimalist 1-page PDF showing "Hello, world!"
  static const String dummyPdfBase64 =
      'JVBERi0xLjcKCjEgMCBvYmogICUKPDwKICAvVHlwZSAvQ2F0YWxvZwogIC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAvTWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0KPj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAgL1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSCj4+CiAgPj4KICAvQ29udGVudHMgNSAwIFIKPj4KZW5kb2JqCgo0IDAgb2JqCjw8CiAgL1R5cGUgL0ZvbnQKICAvU3VidHlwZSAvVHlwZTEKICAvQmFzZUZvbnQgL1RpbWVzLVJvbWFuCj4+CmVuZG9iagoKNSAwIG9iagogICUKPDwKICAvTGVuZ3RoIDQ0Cj4+CnN0cmVhbQpCVAo3MCA1MCBURAovRjEgMTIgVGYKKEhlbGxvLCB3b3JsZCEpIFRqCkVUCmVuZHN0cmVhbQplbmRvYmoKCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAxNSAwMDAwMCBuIAowMDAwMDAwMDYzIDAwMDAwIG4gCjAwMDAwMDAxNDkgMDAwMDAgbiAKMDAwMDAwMDI2MSAwMDAwMCBuIAowMDAwMDAwMzUyIDAwMDAwIG4gCnRyYWlsZXIKPDwKICAvU2l6ZSA2CiAgL1Jvb3QgMSAwIFIKPj4Kc3RhcnR4cmVmCjQ0NgolJUVPRgo=';

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
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: AppAdaptiveLayout(mobile: _buildMobileLayout(), desktop: _buildDesktopLayout()),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ----------------------------------------------------
        // KIRI: PDF Viewer (Besar) denga Toolbar Khas Desktop
        // ----------------------------------------------------
        Expanded(
          flex: 7,
          child: AppPdfViewer.data(
            base64Decode(dummyPdfBase64),
            title: 'Surat Perjalanan Dinas.pdf',
            // hideToolbar: false (default), Toolbar akan muncul karena Lebar Desktop memadai
          ),
        ),

        // ----------------------------------------------------
        // KANAN: Panel Properties / Registrasi (mockup)
        // ----------------------------------------------------
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.white,
            child: const Center(
              child: Text('Panel Tab Registrasi / File Info', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // ----------------------------------------------------
        // ATAS: Detail File layaknya Card Status Upload Mobile
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: AppTab(
            labels: const ['File', 'Registrasi'],
            style: AppTabStyle.flat,
            contentHeight: 110,
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
                          const Text(
                            'Surat Perjalanan Dinas.pdf',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '94 KB of 94 KB • Completed',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
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

        // ----------------------------------------------------
        // BAWAH: Rendering PDF Full Screen untuk *Touch Device*
        // ----------------------------------------------------
        Expanded(
          child: AppPdfViewer.data(
            base64Decode(dummyPdfBase64),
            title: 'Surat Perjalanan Dinas.pdf',
            // Di Mobile, toolbar statik disembunyikan agar pembaca bisa leluasa
            // men-scroll, pinch to zoom & interaksi layaknya PDF reader native
            hideToolbar: true,
          ),
        ),
      ],
    );
  }
}
