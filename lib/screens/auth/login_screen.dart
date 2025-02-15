import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mina/provider/auth_provider.dart';
import 'package:mina/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import 'package:mina/theme/color.dart';
import 'package:mina/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savedCredentials = await authProvider.getSavedCredentials();

    if (savedCredentials != null) {
      // Nếu có thông tin đăng nhập đã lưu, tự động đăng nhập
      try {
        await authProvider.login(
            savedCredentials['email']!, savedCredentials['password']!);

        // Chuyển đến màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeTab()),
        );
      } catch (e) {
        // Đăng nhập tự động thất bại
        print('Auto login failed: $e');
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(
            _emailController.text, _passwordController.text,
            rememberMe: _rememberMe);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeTab()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/logo.svg',
                    width: 101, height: 50),
                const SizedBox(height: 8),
                const Text('Smart consumption',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 12),
                _buildRememberMeAndForgotPassword(),
                const SizedBox(height: 16),
                _buildLoginButton(),
                const SizedBox(height: 2),
                _buildSignUpRedirect(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}")
            .hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) =>
                  setState(() => _rememberMe = value ?? false),
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Forgot Password?'),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D61E7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Log In',
                style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildSignUpRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignUpScreen())),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
