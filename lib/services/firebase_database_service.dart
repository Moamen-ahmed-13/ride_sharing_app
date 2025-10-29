import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Get reference to a path
  DatabaseReference getReference(String path) {
    return _database.ref(path);
  }

  // Save data
  Future<void> saveData(String path, Map<String, dynamic> data) async {
    try {
      await _database.ref(path).set(data);
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }

  // Update data
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _database.ref(path).update(data);
    } catch (e) {
      print('Error updating data: $e');
      rethrow;
    }
  }

  // Get data once
  Future<Map<String, dynamic>?> getData(String path) async {
    try {
      DatabaseEvent event = await _database.ref(path).once();
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error getting data: $e');
      return null;
    }
  }

  // Listen to data changes
  Stream<Map<String, dynamic>?> listenToData(String path) {
    return _database.ref(path).onValue.map((event) {
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  // Delete data
  Future<void> deleteData(String path) async {
    try {
      await _database.ref(path).remove();
    } catch (e) {
      print('Error deleting data: $e');
      rethrow;
    }
  }

  // Query data
  Future<List<Map<String, dynamic>>> queryData(
    String path, {
    String? orderByChild,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
  }) async {
    try {
      Query query = _database.ref(path);

      if (orderByChild != null) {
        query = query.orderByChild(orderByChild);
      }

      if (equalTo != null) {
        query = query.equalTo(equalTo);
      }

      if (limitToFirst != null) {
        query = query.limitToFirst(limitToFirst);
      }

      if (limitToLast != null) {
        query = query.limitToLast(limitToLast);
      }

      DatabaseEvent event = await query.once();
      
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> values = event.snapshot.value as Map;
        return values.entries
            .map((entry) => Map<String, dynamic>.from(entry.value as Map))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error querying data: $e');
      return [];
    }
  }
}
