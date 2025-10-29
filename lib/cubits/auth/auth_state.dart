// part of 'auth_cubit.dart';

// abstract class AuthState extends Equatable {
//   const AuthState();

//   @override
//   List get props => [];
// }

// class AuthInitial extends AuthState {}

// class AuthLoading extends AuthState {}

// class Authenticated extends AuthState {
//   final UserModel user;

//   const Authenticated(this.user);

//   @override
//   List get props => [user];
// }

// class Unauthenticated extends AuthState {}

// class AuthError extends AuthState {
//   final String message;

//   const AuthError(this.message);

//   @override
//   List get props => [message];
// }

import 'package:ride_sharing_app/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String userRole;

  AuthAuthenticated({required this.user, required this.userRole});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}