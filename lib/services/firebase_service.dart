// flutter_app/lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
// import '../models/application_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Management
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.userId)
          .set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Application Management
  Future<void> saveApplication(
    String userId, 
    String applicationId, 
    Map<String, dynamic> applicationData
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('applications')
          .doc(applicationId)
          .set(applicationData);
    } catch (e) {
      throw Exception('Failed to save application: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserApplications(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('applications')
          .orderBy('submitted_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw Exception('Failed to get user applications: $e');
    }
  }

  Future<Map<String, dynamic>?> getApplication(
    String userId, 
    String applicationId
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('applications')
          .doc(applicationId)
          .get();

      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get application: $e');
    }
  }

  // Real-time listeners
  Stream<List<Map<String, dynamic>>> getUserApplicationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('applications')
        .orderBy('submitted_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Current user helper
  String? get currentUserId => _auth.currentUser?.uid;
  
  bool get isAuthenticated => _auth.currentUser != null;

  // Delete application
  Future<void> deleteApplication(String userId, String applicationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('applications')
          .doc(applicationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete application: $e');
    }
  }

  // Batch operations
  Future<void> batchSaveApplications(
    String userId,
    List<Map<String, dynamic>> applications,
  ) async {
    try {
      final batch = _firestore.batch();
      
      for (final app in applications) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('applications')
            .doc();
        batch.set(docRef, app);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch save applications: $e');
    }
  }
}
