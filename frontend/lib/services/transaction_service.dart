import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_transaction.dart';

/// Service for managing user compression transactions in Firestore.
class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for transactions
  CollectionReference<Map<String, dynamic>> _transactionsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  /// Add a new compression transaction
  Future<String> addTransaction({
    required String userId,
    required String originalFileName,
    required int originalSizeBytes,
    required int compressedSizeBytes,
    required double compressionRatio,
  }) async {
    final docRef = await _transactionsRef(userId).add({
      'userId': userId,
      'originalFileName': originalFileName,
      'originalSizeBytes': originalSizeBytes,
      'compressedSizeBytes': compressedSizeBytes,
      'compressionRatio': compressionRatio,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Get all transactions for a user
  Future<List<UserTransaction>> getUserTransactions(String userId) async {
    final snapshot =
        await _transactionsRef(
          userId,
        ).orderBy('timestamp', descending: true).get();

    return snapshot.docs
        .map((doc) => UserTransaction.fromFirestore(doc))
        .toList();
  }

  /// Stream of user transactions (real-time updates)
  Stream<List<UserTransaction>> streamUserTransactions(String userId) {
    return _transactionsRef(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => UserTransaction.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Get transaction count for a user
  Future<int> getTransactionCount(String userId) async {
    final snapshot = await _transactionsRef(userId).count().get();
    return snapshot.count ?? 0;
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _transactionsRef(userId).doc(transactionId).delete();
  }

  /// Get total bytes saved across all transactions
  Future<int> getTotalBytesSaved(String userId) async {
    final transactions = await getUserTransactions(userId);
    return transactions.fold<int>(
      0,
      (total, t) => total + (t.originalSizeBytes - t.compressedSizeBytes),
    );
  }
}
