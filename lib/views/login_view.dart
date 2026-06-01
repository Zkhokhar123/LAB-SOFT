import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
      _successMessage = null;
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
    _animationController.reset();
    _animationController.forward();
  }


  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    // Simulate small latency for clean visual processing effect
    await Future.delayed(const Duration(milliseconds: 600));

    if (_isRegistering) {
      if (password != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = "Passwords do not match!";
          _isSubmitting = false;
        });
        return;
      }
      final success = await authController.register(username, password);
      if (success) {
        setState(() {
          _successMessage = "Offline Account '$username' created successfully! Please login.";
          _isRegistering = false;
          _isSubmitting = false;
          _usernameController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        setState(() {
          _errorMessage = "Username already exists in offline storage.";
          _isSubmitting = false;
        });
      }
    } else {
      final success = await authController.login(username, password);
      if (success) {
        // Success, session automatically handled by listener in AuthWrapper
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text("Welcome back, $username!"),
                ],
              ),
              backgroundColor: Colors.teal[800],
              behavior: SnackBarBehavior.floating,
              width: 320,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = "Invalid username or password offline!";
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(40.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Branding Header ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.science, color: Color(0xFF1E3A8A), size: 40),
                            const SizedBox(width: 8),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A)),
                                children: [
                                  TextSpan(text: 'SHAH-RUKN-ALAM ', style: TextStyle(color: Color(0xFF1E3A8A))),
                                  TextSpan(text: 'LAB', style: TextStyle(color: Colors.lightBlue)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Laboratory Management System',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // --- Mode Header ---
                        Text(
                          _isRegistering ? 'Register Offline Sub-Admin' : 'Secure Admin Login',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF203A43),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isRegistering 
                              ? 'Create a login saved completely on this device' 
                              : 'Sign in to access your offline dashboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Success / Error Feedback Card ---
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[800]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red[800], fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_successMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.green[800]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: TextStyle(color: Colors.green[800], fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // --- Form Fields ---
                        TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'e.g. admin',
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.teal, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.teal, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 4) {
                              return 'Password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        if (_isRegistering) ...[
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_clock_outlined, color: Colors.teal),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.teal,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (_isRegistering) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ],


                        // --- Submit Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    _isRegistering ? 'CREATE OFFLINE ACCOUNT' : 'SECURE SIGN IN',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Toggle Mode link ---
                        TextButton(
                          onPressed: _isSubmitting ? null : _toggleMode,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.teal[800],
                          ),
                          child: Text(
                            _isRegistering
                                ? 'Already have an offline account? Sign In'
                                : 'Need a new local account? Register Offline',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        const Divider(height: 32),

                        // --- Offline Storage Label ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              'Offline Secure Mode: No internet required',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
