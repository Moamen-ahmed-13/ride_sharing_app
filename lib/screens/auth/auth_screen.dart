import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_sharing_app/cubits/auth/auth_cubit.dart';
import 'package:ride_sharing_app/cubits/auth/auth_state.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  bool _isSignIn = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _role = 'rider';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isSignIn = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  }

  String? _validateVehicleType(String? value) {
    if (_role == 'driver' && (value == null || value.isEmpty)) {
      return 'Please enter vehicle type';
    }
    return null;
  }

  String? _validateVehicleNumber(String? value) {
    if (_role == 'driver' && (value == null || value.isEmpty)) {
      return 'Please enter vehicle number';
    }
    return null;
  }

  String? _validateLicenseNumber(String? value) {
    if (_role == 'driver' && (value == null || value.isEmpty)) {
      return 'Please enter license number';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignIn) {
        context.read<AuthCubit>().signIn(email, password);
      } else {
        context.read<AuthCubit>().signUp(
          email,
          password,
          _nameController.text.trim(),
          _phoneController.text.trim(),
          _role,
          _role == 'driver' ? _vehicleTypeController.text.trim() : null,
          _role == 'driver' ? _vehicleNumberController.text.trim() : null,
          _role == 'driver' ? _licenseNumberController.text.trim() : null,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 50,
                          color: theme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 24),

                      Text(
                        'RideShare',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your journey starts here',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      SizedBox(height: 40),

                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(24),
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.grey[600],
                                  tabs: [
                                    Tab(text: 'Sign In'),
                                    Tab(text: 'Sign Up'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),

                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _validateEmail,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),
                                    SizedBox(height: 16),

                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      validator: _validatePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),

                                    if (!_isSignIn) ...[
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        validator: _validateConfirmPassword,
                                        decoration: InputDecoration(
                                          labelText: 'Confirm Password',
                                          prefixIcon: Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      TextFormField(
                                        controller: _nameController,
                                        validator: _validateName,
                                        decoration: InputDecoration(
                                          labelText: 'Full Name',
                                          prefixIcon: Icon(
                                            Icons.person_outline,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        validator: _validatePhone,
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon: Icon(
                                            Icons.phone_outlined,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[50],
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'I am a:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Spacer(),
                                            DropdownButton<String>(
                                              value: _role,
                                              underline: SizedBox(),
                                              items: [
                                                DropdownMenuItem(
                                                  value: 'rider',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Rider'),
                                                    ],
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'driver',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.drive_eta,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Driver'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  _role = value!;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (_role == 'driver') ...[
                                        SizedBox(height: 16),

                                        TextFormField(
                                          controller: _vehicleTypeController,
                                          validator: _validateVehicleType,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Vehicle Type (e.g., Sedan, SUV)',
                                            prefixIcon: Icon(
                                              Icons.directions_car_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        TextFormField(
                                          controller: _vehicleNumberController,
                                          validator: _validateVehicleNumber,
                                          decoration: InputDecoration(
                                            labelText: 'Vehicle Number',
                                            prefixIcon: Icon(
                                              Icons.pin_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        TextFormField(
                                          controller: _licenseNumberController,
                                          validator: _validateLicenseNumber,
                                          decoration: InputDecoration(
                                            labelText: 'License Number',
                                            prefixIcon: Icon(
                                              Icons.credit_card_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                          ),
                                        ),
                                      ],
                                    ],

                                    SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: state is AuthLoading
                                            ? null
                                            : _handleSubmit,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: state is AuthLoading
                                            ? SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                _isSignIn
                                                    ? 'Sign In'
                                                    : 'Sign Up',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
