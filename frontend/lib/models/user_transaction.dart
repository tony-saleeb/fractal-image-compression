import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/file_size_extension.dart';

/// Represents a compression transaction for a user.
class UserTransaction {
  final String id;
  final String userId;
  final String originalFileName;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final double compressionRatio;
  final DateTime timestamp;

  UserTransaction({
    required this.id,
    required this.userId,
    required this.originalFileName,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.compressionRatio,
    required this.timestamp,
  });

  /// Create from Firestore document
  factory UserTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      originalFileName: data['originalFileName'] ?? 'Unknown',
      originalSizeBytes: data['originalSizeBytes'] ?? 0,
      compressedSizeBytes: data['compressedSizeBytes'] ?? 0,
      compressionRatio: (data['compressionRatio'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'originalFileName': originalFileName,
      'originalSizeBytes': originalSizeBytes,
      'compressedSizeBytes': compressedSizeBytes,
      'compressionRatio': compressionRatio,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Human-readable original size
  String get formattedOriginalSize => originalSizeBytes.toHumanReadableSize();

  /// Human-readable compressed size
  String get formattedCompressedSize =>
      compressedSizeBytes.toHumanReadableSize();

  /// Human-readable compression ratio
  String get formattedRatio => '${compressionRatio.toStringAsFixed(1)}%';
}
