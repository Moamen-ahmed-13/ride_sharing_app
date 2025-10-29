// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ride_sharing_app/core/constants/app_colors.dart';
// import 'package:ride_sharing_app/core/constants/app_strings.dart';
// import 'package:ride_sharing_app/core/widgets/custom_button.dart';
// import 'package:ride_sharing_app/core/widgets/custom_text_field.dart';
// import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
// import 'package:ride_sharing_app/features/common/presentation/pages/mode_selection_screen.dart';
// import 'package:ride_sharing_app/features/common/presentation/pages/register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State {
//   final _formKey = GlobalKey();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleLogin() {
//     if (_formKey.currentState!.validate()) {
//       context.read<AuthCubit>().login(
//             _emailController.text.trim(),
//             _passwordController.text,
//           );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener(
//         listener: (context, state) {
//           if (state is Authenticated) {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
//             );
//           } else if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: AppColors.error,
//               ),
//             );
//           }
//         },
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 60),
//                   const Icon(
//                     Icons.local_taxi,
//                     size: 60,
//                     color: AppColors.primary,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Welcome Back!',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Login to continue',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 48),
//                   CustomTextField(
//                     label: AppStrings.email,
//                     hint: 'Enter your email',
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     prefixIcon: const Icon(Icons.email_outlined),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       if (!value.contains('@')) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   CustomTextField(
//                     label: AppStrings.password,
//                     hint: 'Enter your password',
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       if (value.length < 6) {
//                         return 'Password must be at least 6 characters';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 32),
//                   BlocBuilder(
//                     builder: (context, state) {
//                       return CustomButton(
//                         text: AppStrings.login,
//                         onPressed: _handleLogin,
//                         isLoading: state is AuthLoading,
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Don't have an account? ",
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => const RegisterScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Register',
//                           style: TextStyle(
//                             color: AppColors.primary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }