import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mina/provider/auth_provider.dart';
import 'package:mina/screens/auth/login_screen.dart';
import 'package:mina/services/api_service.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import 'package:mina/screens/home/home_screen.dart';
import 'package:mina/services/otp_service.dart';
import 'dart:convert';

class OtpScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String password;

  const OtpScreen({
    Key? key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final OTPService _otpService = OTPService();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  int _remainingTime = 600; // 10 phút
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_remainingTime > 0 && mounted) {
        setState(() {
          _remainingTime--;
        });
        _startTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String get _formattedTime {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _otpService.requestOTP(widget.email);
      if (!result['success']) {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể gửi mã OTP. Vui lòng thử lại.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (pinController.text.length != 6) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đủ 6 số';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String otpCode = pinController.text;
      print('Verifying OTP: $otpCode');

      final result = await _otpService.verifyOTP(widget.email, otpCode);
      print('Verify result: $result');

      if (result['success'] == true) {
        print('OTP verification successful');

        // Show success message for OTP verification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP xác thực thành công'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Proceed with registration
        try {
          final registerResult = await _authService.register(
            "${widget.firstName} ${widget.lastName}",
            widget.email,
            widget.password,
          );
          print('Register result: $registerResult');

          if (registerResult['status'] == 'success') {
            if (!mounted) return;

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to login screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          } else {
            // Registration failed
            if (!mounted) return;
            setState(() {
              _errorMessage =
                  registerResult['message'] ?? 'Đăng ký không thành công';
            });
          }
        } catch (e) {
          print('Registration error: $e');
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Lỗi đăng ký tài khoản: ${e.toString()}';
          });
        }
      } else {
        // OTP verification failed
        setState(() {
          _errorMessage = result['message'] ?? 'Mã OTP không hợp lệ';
        });
      }
    } catch (e) {
      print('OTP verification error: $e');
      setState(() {
        _errorMessage = 'Lỗi xác thực: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleResendOTP() {
    if (_canResend) {
      setState(() {
        _remainingTime = 600;
        _canResend = false;
      });
      _sendOTP();
      _startTimer();
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(55, 171, 102, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color(0xFF3366CC);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: SvgPicture.asset(
                      'assets/icons/otp.svg',
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verify Account!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter 6-digit Code code we have sent to at',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Form(
                      key: formKey,
                      child: Pinput(
                        length: 6,
                        controller: pinController,
                        focusNode: focusNode,
                        defaultPinTheme: defaultPinTheme,
                        enabled: !_isLoading,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        errorPinTheme: defaultPinTheme.copyBorderWith(
                          border: Border.all(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Time remaining: $_formattedTime',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _canResend ? _handleResendOTP : null,
                        child: Text(
                          'Resend Code',
                          style: TextStyle(
                            color: _canResend ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D61E7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: Colors.blue.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
