// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:ride_sharing_app/features/common/data/datasources/auth_remote_datasource.dart';
// import 'package:ride_sharing_app/features/models/user_model.dart';

// part 'auth_state.dart';

// class AuthCubit extends Cubit {
//   final AuthRemoteDatasource _authDataSource;

//   AuthCubit(this._authDataSource) : super(AuthInitial()) {
//     _checkAuthStatus();
//   }

//   Future _checkAuthStatus() async {
//     emit(AuthLoading());
//     try {
//       final user = await _authDataSource.getCurrentUser();
//       if (user != null) {
//         emit(Authenticated(user));
//       } else {
//         emit(Unauthenticated());
//       }
//     } catch (e) {
//       emit(Unauthenticated());
//     }
//   }

//   Future login(String email, String password) async {
//     emit(AuthLoading());
//     try {
//       final user = await _authDataSource.login(email, password);
//       emit(Authenticated(user));
//     } catch (e) {
//       emit(AuthError(e.toString()));
//       emit(Unauthenticated());
//     }
//   }

//   Future register({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//   }) async {
//     emit(AuthLoading());
//     try {
//       final user = await _authDataSource.register(
//         email: email,
//         password: password,
//         name: name,
//         phone: phone,
//       );
//       emit(Authenticated(user));
//     } catch (e) {
//       emit(AuthError(e.toString()));
//       emit(Unauthenticated());
//     }
//   }

//   Future logout() async {
//     emit(AuthLoading());
//     await _authDataSource.logout();
//     emit(Unauthenticated());
//   }

//   Future switchMode(UserMode mode) async {
//     if (state is Authenticated) {
//       final currentUser = (state as Authenticated).user;
//       try {
//         await _authDataSource.switchMode(currentUser.id as UserMode, mode as String);
//         emit(Authenticated(currentUser.copyWith(currentMode: mode)));
//       } catch (e) {
//         emit(AuthError('Failed to switch mode: $e'));
//       }
//     }
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ride_sharing_app/models/user_model.dart';
import 'package:ride_sharing_app/services/fcm_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FCMService _fcmService = FCMService();

  AuthCubit() : super(AuthInitial());

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      try {
        // Fetch user data from database
        DatabaseEvent event = await _database
            .ref('users/${firebaseUser.uid}')
            .once();

        if (event.snapshot.value != null) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(
            event.snapshot.value as Map,
          );
          UserModel user = UserModel.fromMap(userData);

          emit(AuthAuthenticated(user: user, userRole: user.role));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError('Failed to load user data: ${e.toString()}'));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role, // 'rider' or 'driver'
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
  }) async {
    try {
      emit(AuthLoading());

      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      
      // Get FCM token
      String? fcmToken = await _fcmService.getToken();

      // Create user model
      UserModel user = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        fcmToken: fcmToken,
        rating: 5.0,
        vehicleType: role == 'driver' ? vehicleType : null,
        vehicleNumber: role == 'driver' ? vehicleNumber : null,
        licenseNumber: role == 'driver' ? licenseNumber : null,
        isAvailable: role == 'driver' ? true : null,
      );

      // Save user data to Firebase Realtime Database
      await _database.ref('users/$uid').set(user.toMap());

      emit(AuthAuthenticated(user: user, userRole: role));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign up failed'));
    } catch (e) {
      emit(AuthError('An error occurred: ${e.toString()}'));
    }
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Fetch user data
      DatabaseEvent event = await _database.ref('users/$uid').once();
      
      if (event.snapshot.value != null) {
        Map<String, dynamic> userData = 
            Map<String, dynamic>.from(event.snapshot.value as Map);
        UserModel user = UserModel.fromMap(userData);
        
        // Update FCM token
        String? fcmToken = await _fcmService.getToken();
        await _database.ref('users/$uid/fcmToken').set(fcmToken);

        emit(AuthAuthenticated(user: user, userRole: user.role));
      } else {
        emit(AuthError('User data not found'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign in failed'));
    } catch (e) {
      emit(AuthError('An error occurred: ${e.toString()}'));
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign out failed: ${e.toString()}'));
    }
  }

  // Switch role (if needed)
  Future<void> switchRole(String newRole, {
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
  }) async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      Map<String, dynamic> updates = {'role': newRole};
      
      if (newRole == 'driver') {
        updates['vehicleType'] = vehicleType;
        updates['vehicleNumber'] = vehicleNumber;
        updates['licenseNumber'] = licenseNumber;
        updates['isAvailable'] = true;
      }

      await _database.ref('users/${firebaseUser.uid}').update(updates);
      
      // Reload user data
      await checkAuthStatus();
    } catch (e) {
      emit(AuthError('Failed to switch role: ${e.toString()}'));
    }
  }
}
