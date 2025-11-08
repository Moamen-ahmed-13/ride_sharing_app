import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';
import 'package:ride_sharing_app/models/user_model.dart';
import 'package:ride_sharing_app/services/auth_service.dart';
import 'package:ride_sharing_app/services/firebase_database_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final DatabaseService _databaseService;
  StreamSubscription<User?>? _userSubscription;

  AuthCubit({
    required AuthService authService,
    required DatabaseService databaseService,
  }) : _authService = authService,
       _databaseService = databaseService,
       super(AuthInitial()) {
    _checkAuthStatus();
  }
  Future<void> _checkAuthStatus() async {
    if (_authService.currentUser != null) {
      emit(AuthLoading());
      _listenToUser();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String name,
    required String phone,
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.signUp(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        name: name,
        phone: phone,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
      );
      _listenToUser();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.signIn(email, password);
      _listenToUser();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _listenToUser() {
    _userSubscription?.cancel();
    if (_authService.currentUser != null) {
      final uid = _authService.currentUser!.uid;

      _userSubscription = _databaseService
          .getUserStream(uid)
          .listen(
            (user) {
              if (user != null) {
                print('✅ User loaded: ${user.email} (${user.role})');
                emit(AuthAuthenticated(user: user));
              } else {
                print('❌ User data not found in database');
                emit(AuthError('User data not found'));
              }
            },
            onError: (error) {
              print('❌ Error listening to user: $error');
              emit(AuthError('Error loading user data: $error'));
            },
            cancelOnError: false,
          );
    }
  }

  Future<void> signOut() async {
    try {
  await _authService.signOut();
 await _userSubscription?.cancel();
_userSubscription = null;
  emit(AuthInitial());
} on Exception catch (e) {
  emit(AuthError('Sign out failed: ${e.toString()}'));

}  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
