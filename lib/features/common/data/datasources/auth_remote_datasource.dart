// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ride_sharing_app/models/user_model.dart';

// class AuthRemoteDatasource {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future login(String email, String password) async {
//     try {
//       UserCredential userCredential = await _firebaseAuth
//           .signInWithEmailAndPassword(email: email, password: password);
//       final doc = await _firestore
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .get();
//       return UserModel.fromJson({
//         ...doc.data()!,
//         'id': userCredential.user!.uid,
//       });
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         throw Exception('No user found for that email.');
//       } else if (e.code == 'wrong-password') {
//         throw Exception('Wrong password provided for that user.');
//       }
//     }
//   }

//   Future register({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//   }) async {
//     try {
//       UserCredential userCredential = await _firebaseAuth
//           .createUserWithEmailAndPassword(email: email, password: password);
//       final user = UserModel(
//         id: userCredential.user!.uid,
//         name: name,
//         email: email,
//         phone: phone,
//         currentMode: UserMode.rider,
//       );
//       await _firestore
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set(user.toJson() as Map<String, dynamic>);
//       return user;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         throw Exception('The password provided is too weak.');
//       } else if (e.code == 'email-already-in-use') {
//         throw Exception('The account already exists for that email.');
//       }
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   Future logout() async {
//     await _firebaseAuth.signOut();
//   }

//   Future getCurrentUser() async {
//     final user = _firebaseAuth.currentUser;
//     if (user != null) {
//       final doc = await _firestore.collection('users').doc(user.uid).get();
//       if (!doc.exists) return null;
//       return UserModel.fromJson({...doc.data()!, 'id': user.uid});
//     }
//   }
//   Future switchMode(UserMode mode, String userId) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .update({'currentMode': mode == UserMode.driver ? 'driver' : 'rider'});
//   }
// }
