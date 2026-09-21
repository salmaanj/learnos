import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/certificate_model.dart';

class CertificatePdfViewerScreen extends StatefulWidget {
  final File file;
  final CertificateModel certificate;

  const CertificatePdfViewerScreen({
    super.key,
    required this.file,
    required this.certificate,
  });

  @override
  State<CertificatePdfViewerScreen> createState() =>
      _CertificatePdfViewerScreenState();
}

class _CertificatePdfViewerScreenState
    extends State<CertificatePdfViewerScreen> {
  bool _isReady = false;
  String? _error;

  Future<void> _shareCertificate() async {
    try {
      await Share.shareXFiles(
        [
          XFile(
            widget.file.path,
            mimeType: 'application/pdf',
            name: 'LearnOS-${widget.certificate.courseTitle}.pdf',
          ),
        ],
        subject: 'LearnOS Certificate - ${widget.certificate.courseTitle}',
        text:
        'LearnOS Certificate for ${widget.certificate.courseTitle}. '
            'Verification code: ${widget.certificate.verificationCode}',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to share the certificate PDF.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Certificate',
          style: AppTextStyles.h4,
        ),
        actions: [
          IconButton(
            tooltip: 'Share or save PDF',
            onPressed: _shareCertificate,
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.file.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            fitPolicy: FitPolicy.BOTH,
            onRender: (_) {
              if (!mounted) {
                return;
              }

              setState(() {
                _isReady = true;
              });
            },
            onError: (error) {
              if (!mounted) {
                return;
              }

              setState(() {
                _error = error.toString();
              });
            },
            onPageError: (_, error) {
              if (!mounted) {
                return;
              }

              setState(() {
                _error = error.toString();
              });
            },
          ),
          if (!_isReady && _error == null)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to open certificate',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
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