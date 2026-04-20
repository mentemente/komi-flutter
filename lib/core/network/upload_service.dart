import 'package:image_picker/image_picker.dart';
import 'package:komi_fe/core/network/http_client.dart';

class UploadService {
  UploadService(this._client);

  final HttpClient _client;

  static String _sanitizeFilename(String name) {
    var filename = name.trim();
    if (filename.isEmpty) {
      return 'payment_qr.jpg';
    }
    if (!filename.contains('.')) {
      filename = '$filename.jpg';
    }
    return filename;
  }

  Future<Map<String, dynamic>> uploadPaymentQrBytes(
    List<int> bytes, {
    required String filename,
  }) {
    return _client.postMultipart(
      '/v1/upload/image',
      fields: const {'type': 'payment_qr'},
      fileFieldName: 'image',
      fileBytes: bytes,
      filename: _sanitizeFilename(filename),
    );
  }

  Future<Map<String, dynamic>> uploadPaymentQrImage(XFile file) async {
    final bytes = await file.readAsBytes();
    return uploadPaymentQrBytes(bytes, filename: file.name);
  }

  Future<Map<String, dynamic>> uploadPaymentOrderBytes(
    List<int> bytes, {
    required String filename,
  }) {
    return _client.postMultipart(
      '/v1/upload/image',
      fields: const {'type': 'payment_order'},
      fileFieldName: 'image',
      fileBytes: bytes,
      filename: _sanitizeFilename(filename),
    );
  }

  Future<Map<String, dynamic>> uploadPaymentOrderImage(XFile file) async {
    final bytes = await file.readAsBytes();
    return uploadPaymentOrderBytes(bytes, filename: file.name);
  }
}
