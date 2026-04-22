import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'compression_service.dart';

/// Professional Controller for managing Neural Compression state and flow.
/// This acts as the ViewModel in our MVVM architecture.
class CompressionController extends ChangeNotifier {
  final CompressionService _service = CompressionService();
  
  bool _isProcessing = false;
  String? _errorMessage;
  CompressionResult? _lastCompressResult;
  DecompressionResult? _lastDecompressResult;

  // Getters
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  CompressionResult? get lastCompressResult => _lastCompressResult;
  DecompressionResult? get lastDecompressResult => _lastDecompressResult;

  /// Clear the current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if server is running
  Future<bool> checkServerStatus() async {
    return await _service.isServerRunning();
  }

  /// Core logic for handling Image Compression
  /// Returns a Future that completes when the API call is done, 
  /// allowing the Loading Overlay to synchronize.
  Future<CompressionResult?> performCompression({
    required PlatformFile pickedFile,
    required Uint8List imageBytes,
  }) async {
    // 1. Immediate guard against double-triggering
    if (_isProcessing) return null;
    
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final File imageFile = (kIsWeb || pickedFile.path == null) 
          ? File('') 
          : File(pickedFile.path!);

      final result = await _service.compressImage(
        imageFile: (kIsWeb || pickedFile.path == null) ? null : imageFile,
        imageBytes: kIsWeb ? imageBytes : null,
        filename: pickedFile.name,
      );

      _lastCompressResult = result;
      return result;
    } on CompressionException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      // Note: We don't set _isProcessing = false here yet because 
      // the UI is still transitionary toward the result screen.
      // We rely on the UI to signal completion or the finally block
      // below after navigation.
    }
  }

  /// Core logic for handling .fic Decompression
  Future<DecompressionResult?> performDecompression({
    required PlatformFile pickedFile,
    required Uint8List ficBytes,
  }) async {
    if (_isProcessing) return null;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.decompressBytes(
        ficBytes,
        filename: pickedFile.name,
      );
      _lastDecompressResult = result;
      return result;
    } on CompressionException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  /// Signals that the UI is done with the processing phase (overlay closed).
  void setProcessing(bool value) {
    if (_isProcessing != value) {
      _isProcessing = value;
      notifyListeners();
    }
  }
}
