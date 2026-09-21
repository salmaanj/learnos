import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/certificate_model.dart';

class CertificateService {
  final Dio _dio = ApiClient().dio;

  Future<List<CertificateModel>> getMyCertificates() async {
    try {
      final response = await _dio.get(ApiConstants.myCertificates);

      final body = response.data;
      dynamic data = body;

      if (body is Map && body['data'] != null) {
        data = body['data'];
      }

      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map>()
          .map(
            (item) => CertificateModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  Future<File> downloadCertificatePdf(CertificateModel certificate) async {
    try {
      final directory = await getTemporaryDirectory();

      final safeCourseTitle = _safeFilePart(certificate.courseTitle);
      final safeLearnerName = _safeFilePart(certificate.learnerName);

      final file = File(
        '${directory.path}/LearnOS-$safeCourseTitle-$safeLearnerName.pdf',
      );

      await _dio.download(
        ApiConstants.certificateDownload(certificate.id),
        file.path,
        deleteOnError: true,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (!await file.exists() || await file.length() == 0) {
        throw Exception('The certificate PDF could not be downloaded.');
      }

      return file;
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  String _safeFilePart(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return cleaned.isEmpty ? 'Certificate' : cleaned;
  }

  String _extractError(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;

    if (body is Map) {
      final message = body['message'] ?? body['error'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (statusCode == 401) {
      return 'Your session has expired. Please log in again.';
    }

    if (statusCode == 403) {
      return 'You do not have permission to access this certificate.';
    }

    if (statusCode == 404) {
      return 'Certificate not found.';
    }

    return error.message ?? 'Unable to load certificates.';
  }
}