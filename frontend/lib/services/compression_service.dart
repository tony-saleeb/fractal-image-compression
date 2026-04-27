import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/file_size_extension.dart';

/// Maximum time to wait for a server response. Large images on CPU can
/// take 3-5 minutes; set this high enough to never cut off a valid job.
const _kRequestTimeout = Duration(minutes: 60);

/// Whether the user wants to compress an image or decompress a .fic file.
enum CompressionMode { compress, decompress }


/// Base URL of the FractalCompression backend server.
/// - Web & desktop (local dev): http://localhost:8000
/// - Android emulator talking to localhost: http://10.0.2.2:8000
/// - Physical device on same Wi-Fi: replace with your machine's local IP
const String _kBaseUrl = 'https://tony-saleeb-deepfract-api.hf.space';

/// Service for compressing / decompressing images via the FractalCompression
/// FastAPI backend (server.py).  The server must be running before calling
/// these methods:
///
///   py server.py   (in c:\Users\TONY\Development\fractal)
///
class CompressionService {
  /// Compress [imageFile] (mobile) or [imageBytes] + [filename] (web/bytes).
  /// Returns [CompressionResult] with sizes, ratio, and the raw .fic bytes.
  Future<CompressionResult> compressImage({
    File? imageFile,
    Uint8List? imageBytes,
    String filename = 'image.jpg',
  }) async {
    assert(imageFile != null || imageBytes != null,
        'Provide either imageFile or imageBytes');

    try {
      final uri = Uri.parse('$_kBaseUrl/compress');
      final request = http.MultipartRequest('POST', uri);

      // Attach image
      if (!kIsWeb && imageFile != null) {
        final originalSize = await imageFile.length();
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        final streamedResponse =
            await request.send().timeout(_kRequestTimeout);
        return _handleCompressResponse(
          streamedResponse,
          originalSize,
          imageFile: imageFile,
        );
      } else {
        // Web or bytes path
        request.files.add(
          http.MultipartFile.fromBytes('image', imageBytes!,
              filename: filename),
        );
        final streamedResponse =
            await request.send().timeout(_kRequestTimeout);
        return _handleCompressResponse(
          streamedResponse,
          imageBytes.length,
          imageBytes: imageBytes,
        );
      }
    } on TimeoutException {
      throw const CompressionException(
        'Server took too long to respond (>5 min).\n'
        'Try a smaller image, or set FC_MAX_DIM on the server.',
        code: 'TIMEOUT',
      );
    } on SocketException catch (e) {
      throw CompressionException(
        'Cannot connect to FractalCompression server at $_kBaseUrl.\n'
        'Make sure server.py is running: py server.py',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } catch (e) {
      throw CompressionException.failed(e);
    }
  }

  Future<CompressionResult> _handleCompressResponse(
    http.StreamedResponse streamedResponse,
    int originalSize, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw CompressionException.serverError(streamedResponse.statusCode,
          detail: body);
    }

    final ficBytes = await streamedResponse.stream.toBytes();
    final headers = streamedResponse.headers;

    final ratio = double.tryParse(headers['x-ratio'] ?? '') ?? 0;
    final psnr = double.tryParse(headers['x-psnr'] ?? '') ?? 0;
    final rmse = double.tryParse(headers['x-rmse'] ?? '') ?? 0;
    final elapsed = double.tryParse(headers['x-time'] ?? '') ?? 0;
    final width = int.tryParse(headers['x-width'] ?? '') ?? 0;
    final height = int.tryParse(headers['x-height'] ?? '') ?? 0;

    return CompressionResult(
      originalFile: imageFile ?? File(''),
      imageBytes: imageBytes,
      ficBytes: ficBytes,
      originalSize: originalSize,
      compressedSize: ficBytes.length,
      compressionRatio: ratio,
      psnr: psnr,
      rmse: rmse,
      elapsedSeconds: elapsed,
      width: width,
      height: height,
    );
  }

  /// Decompress a .fic [ficBytes] blob → PNG [Uint8List].
  Future<DecompressionResult> decompressBytes(Uint8List ficBytes,
      {String filename = 'image.fic'}) async {
    try {
      final uri = Uri.parse('$_kBaseUrl/decompress');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes('fic', ficBytes, filename: filename),
        );

      final streamed =
          await request.send().timeout(_kRequestTimeout);
      if (streamed.statusCode != 200) {
        final body = await streamed.stream.bytesToString();
        throw CompressionException.serverError(streamed.statusCode,
            detail: body);
      }
      final decodedBytes = await streamed.stream.toBytes();
      final elapsed = double.tryParse(streamed.headers['x-time'] ?? '') ?? 0.0;
      return DecompressionResult(decodedBytes, elapsed);
    } on TimeoutException {
      throw const CompressionException(
        'Decompression timed out (>5 min). The .fic file may be corrupted.',
        code: 'TIMEOUT',
      );
    } on SocketException catch (e) {
      throw CompressionException(
        'Cannot connect to server at $_kBaseUrl',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    }
  }

  /// Health-check the server.  Returns true if running.
  Future<bool> isServerRunning() async {
    try {
      final res = await http
          .get(Uri.parse('$_kBaseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result model
// ─────────────────────────────────────────────────────────────────────────────

class CompressionResult {
  final File originalFile;
  final Uint8List? imageBytes;  // original image bytes (web)
  final Uint8List ficBytes;     // raw .fic compressed bytes
  final int originalSize;
  final int compressedSize;
  final double compressionRatio; // X:1
  final double psnr;
  final double rmse;
  final double elapsedSeconds;
  final int width;
  final int height;

  const CompressionResult({
    required this.originalFile,
    this.imageBytes,
    required this.ficBytes,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.psnr,
    required this.rmse,
    required this.elapsedSeconds,
    required this.width,
    required this.height,
  });

  String get formattedOriginalSize => originalSize.toHumanReadableSize();
  String get formattedCompressedSize => compressedSize.toHumanReadableSize();
  String get formattedRatio => '${compressionRatio.toStringAsFixed(1)}:1';
  String get formattedPsnr => '${psnr.toStringAsFixed(2)} dB';
  String get formattedRmse => rmse.toStringAsFixed(2);
  String get formattedTime => '${elapsedSeconds.toStringAsFixed(2)}s';
}

class DecompressionResult {
  final Uint8List imageBytes;
  final double elapsedSeconds;

  const DecompressionResult(this.imageBytes, this.elapsedSeconds);
}

// ─────────────────────────────────────────────────────────────────────────────
// Exception
// ─────────────────────────────────────────────────────────────────────────────

class CompressionException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const CompressionException(this.message, {this.code, this.originalError});

  factory CompressionException.serverError(int statusCode, {String? detail}) =>
      CompressionException(
        'Server error $statusCode${detail != null ? ': $detail' : ''}',
        code: 'SERVER_ERROR',
      );

  factory CompressionException.networkError([String? details]) =>
      CompressionException(
        details ?? 'Network connection failed',
        code: 'NETWORK_ERROR',
      );

  factory CompressionException.failed(dynamic error) => CompressionException(
        'Compression failed: $error',
        code: 'FAILED',
        originalError: error,
      );

  @override
  String toString() => 'CompressionException: $message';
}
