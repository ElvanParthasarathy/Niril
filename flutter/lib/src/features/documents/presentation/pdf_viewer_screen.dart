import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:elvan_niril/src/core/services/share_service.dart';

import 'package:elvan_niril/src/features/shell/presentation/mobile/widgets/elvan_back_button.dart';

class PdfViewerScreen extends ConsumerWidget {
  final File pdfFile;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfFile,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareService = ref.watch(shareServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SfPdfViewer.file(
            pdfFile,
            canShowScrollHead: false,
            canShowScrollStatus: false,
          ),
          // Custom Top Bar with Back Button and Share
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16.0,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        color: Colors.black.withValues(alpha: 0.05),
                      )
                    ],
                  ),
                  child: Material(
                    type: MaterialType.canvas,
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(25),
                    clipBehavior: Clip.antiAlias,
                    child: const ElvanBackButton(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        color: Colors.black.withValues(alpha: 0.05),
                      )
                    ],
                  ),
                  child: Material(
                    type: MaterialType.canvas,
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(25),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon:
                          const Icon(CupertinoIcons.share, color: Colors.black),
                      onPressed: () {
                        shareService.shareFile(pdfFile.path,
                            text: 'Check out this document: $title');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
