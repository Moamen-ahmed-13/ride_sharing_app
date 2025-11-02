import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

Future<UserCredential> signUp(String email, String password, String role, String name, String phone, String? vehicleType, String? vehicleNumber, String? licenseNumber) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
        final uid = userCredential.user!.uid;
    await _database.child('users').child(uid).set({
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType, 
      'vehicleNumber': vehicleNumber, 
      'licenseNumber': licenseNumber,
    });

    return userCredential;
  }
  Future<void> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      final snapshot = await _database
          .child('users')
          .child(credential.user!.uid)
          .get();

      if (!snapshot.exists) {
        throw Exception('User data not found. Please contact support.');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final uid = currentUser?.uid;
      if (uid != null) {
        await _database.child('users').child(uid).remove();
        await currentUser?.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}