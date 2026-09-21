import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';
import '../models/certificate_model.dart';
import '../services/certificate_service.dart';
import 'certificate_pdf_viewer_screen.dart';

class MyCertificatesScreen extends StatefulWidget {
  const MyCertificatesScreen({super.key});

  @override
  State<MyCertificatesScreen> createState() => _MyCertificatesScreenState();
}

class _MyCertificatesScreenState extends State<MyCertificatesScreen> {
  final CertificateService _certificateService = CertificateService();

  bool _loading = true;
  String? _error;
  List<CertificateModel> _certificates = [];
  String? _downloadingCertificateId;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final certificates = await _certificateService.getMyCertificates();

      if (!mounted) {
        return;
      }

      setState(() {
        _certificates = certificates;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

  Future<void> _openCertificate(CertificateModel certificate) async {
    if (!certificate.isIssued) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This certificate has been revoked and cannot be downloaded.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _downloadingCertificateId = certificate.id;
    });

    try {
      final file = await _certificateService.downloadCertificatePdf(
        certificate,
      );

      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CertificatePdfViewerScreen(
            file: file,
            certificate: certificate,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloadingCertificateId = null;
        });
      }
    }
  }

  String _friendlyError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          'My Certificates',
          style: AppTextStyles.h3,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          top: false,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: AppLoader());
    }

    if (_error != null) {
      return _CertificateErrorState(
        message: _error!,
        onRetry: _loadCertificates,
      );
    }

    if (_certificates.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadCertificates,
        child: ListView(
          children: const [
            SizedBox(height: 130),
            _CertificateEmptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadCertificates,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemCount: _certificates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final certificate = _certificates[index];

          return _CertificateCard(
            certificate: certificate,
            downloading: _downloadingCertificateId == certificate.id,
            onOpen: () => _openCertificate(certificate),
          );
        },
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final bool downloading;
  final VoidCallback onOpen;

  const _CertificateCard({
    required this.certificate,
    required this.downloading,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isIssued = certificate.isIssued;
    final statusColor = isIssued ? AppColors.success : AppColors.error;
    final statusLabel = isIssued ? 'Issued' : 'Revoked';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isIssued
              ? AppColors.warning.withOpacity(0.45)
              : AppColors.error.withOpacity(0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  certificate.courseTitle.isEmpty
                      ? 'Course Certificate'
                      : certificate.courseTitle,
                  style: AppTextStyles.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: certificate.learnerName.isEmpty
                ? 'Learner'
                : certificate.learnerName,
          ),
          const SizedBox(height: 9),
          _DetailRow(
            icon: Icons.calendar_month_outlined,
            label: 'Issued ${certificate.issueDateLabel}',
          ),
          const SizedBox(height: 9),
          _DetailRow(
            icon: Icons.grade_outlined,
            label: 'Assessment score: ${certificate.scoreLabel}',
          ),
          const SizedBox(height: 9),
          _DetailRow(
            icon: Icons.verified_outlined,
            label: 'Code: ${certificate.verificationCode}',
          ),
          const SizedBox(height: 9),
          _DetailRow(
            icon: Icons.numbers_rounded,
            label: certificate.certificateNumber,
          ),
          if (certificate.companyName != null &&
              certificate.companyName!.trim().isNotEmpty) ...[
            const SizedBox(height: 9),
            _DetailRow(
              icon: Icons.business_outlined,
              label: certificate.companyName!,
            ),
          ],
          if (certificate.isRevoked &&
              certificate.revocationReason != null &&
              certificate.revocationReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                certificate.revocationReason!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isIssued && !downloading ? onOpen : null,
              icon: downloading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
                  : Icon(
                isIssued
                    ? Icons.picture_as_pdf_rounded
                    : Icons.block_rounded,
              ),
              label: Text(
                downloading
                    ? 'Downloading Certificate...'
                    : isIssued
                    ? 'View & Download Certificate'
                    : 'Certificate Revoked',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isIssued ? AppColors.primary : AppColors.textMuted,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CertificateEmptyState extends StatelessWidget {
  const _CertificateEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.warning,
            size: 78,
          ),
          const SizedBox(height: 18),
          Text(
            'No certificates yet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete all course lessons and pass the assessment to earn your certificate.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CertificateErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CertificateErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 68,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load certificates',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}