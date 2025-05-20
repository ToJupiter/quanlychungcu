import 'package:flutter/material.dart';
import '../screens/dashboard_view.dart';
import '../screens/main_layout.dart';
import '../services/auth_service.dart'; // Import AuthService

class LoginView extends StatefulWidget {
  static const String routeName = '/login'; // Added routeName
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _errorMessage = '';
  bool _otpRequired = false; // Non-functional based on backend
  bool _isLoading = false;

  final AuthService _authService = AuthService(); // Instantiate AuthService

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    print('Login attempt with Email: $email, Password: $password');

    try {
      await _authService.loginStaff(email, password); // Call login

      // If loginStaff completes without throwing an exception, it means success.
      // AuthService already saves the token and user details.
      if (mounted) {
        print('Login successful. Navigating to Dashboard.'); 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout(currentRoute: DashboardView.routeName, child: DashboardView())), // Use DashboardView.routeName
        );
      }
      // The 'else' block for failure is now handled by the catch block,
      // as AuthService.loginStaff throws an exception on failure.

    } catch (e) {
      if (mounted) {
        setState(() {
          // _errorMessage = result['message'] ?? 'Login failed. Please try again.'; // Old error handling
          _errorMessage = 'Login failed: ${e.toString().replaceFirst("Exception: ", "")}'; // Display error from exception
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Optional: University/Faculty Header
                      // const Text(
                      //   'University/Faculty Name',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      // ),
                      // const SizedBox(height: 8),
                      const Text(
                        'HỆ THỐNG QUẢN LÝ CHUNG CƯ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tên đăng nhập/email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!value.contains('@')) { // Simple email validation
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // Checkbox for OTP - non-functional as per guidelines
                      Row(
                        children: [
                          Checkbox(
                            value: _otpRequired,
                            onChanged: (bool? value) {
                              // setState(() {
                              //   _otpRequired = value ?? false;
                              // });
                              // Non-functional, so do nothing or keep it disabled
                            },
                            activeColor: Theme.of(context).colorScheme.secondary,
                          ),
                          const Text('Yêu cầu mã OTP mỗi lần đăng nhập', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      _isLoading
                          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Đăng nhập'),
                            ),
                      const SizedBox(height: 16.0),
                      TextButton(
                        onPressed: () {
                          // Non-functional
                          print('Forgot password clicked - non-functional');
                        },
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
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