/// Base class for all application exceptions.
///
/// Provides a consistent interface for error handling across the app.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when image picking/selection fails.
class ImagePickerException extends AppException {
  const ImagePickerException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// User cancelled the image picker
  factory ImagePickerException.cancelled() => const ImagePickerException(
    message: 'Image selection was cancelled',
    code: 'CANCELLED',
  );

  /// Permission was denied
  factory ImagePickerException.permissionDenied([String? details]) =>
      ImagePickerException(
        message: details ?? 'Permission denied to access gallery/camera',
        code: 'PERMISSION_DENIED',
      );

  /// General failure
  factory ImagePickerException.failed(dynamic error) => ImagePickerException(
    message: 'Failed to pick image',
    code: 'FAILED',
    originalError: error,
  );
}

/// Exception thrown when image compression fails.
class CompressionException extends AppException {
  const CompressionException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Server returned an error
  factory CompressionException.serverError(int statusCode) =>
      CompressionException(
        message: 'Server error: $statusCode',
        code: 'SERVER_ERROR',
      );

  /// Network connection failed
  factory CompressionException.networkError([String? details]) =>
      CompressionException(
        message: details ?? 'Network connection failed',
        code: 'NETWORK_ERROR',
      );

  /// General compression failure
  factory CompressionException.failed(dynamic error) => CompressionException(
    message: 'Failed to compress image: $error',
    code: 'FAILED',
    originalError: error,
  );
}

/// Exception thrown when file operations fail.
class FileException extends AppException {
  const FileException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// File not found
  factory FileException.notFound(String path) =>
      FileException(message: 'File not found: $path', code: 'NOT_FOUND');

  /// Failed to read file
  factory FileException.readError(String path, [dynamic error]) =>
      FileException(
        message: 'Failed to read file: $path',
        code: 'READ_ERROR',
        originalError: error,
      );

  /// Failed to write file
  factory FileException.writeError(String path, [dynamic error]) =>
      FileException(
        message: 'Failed to write file: $path',
        code: 'WRITE_ERROR',
        originalError: error,
      );
}
