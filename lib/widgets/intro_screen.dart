import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mina/screens/auth/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  static const int animationDuration = 2; // Thời gian animation (giây)

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: animationDuration),
    );

    // Tạo hiệu ứng scale từ 0 -> 1
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Tạo hiệu ứng fade từ 0 -> 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Bắt đầu animation
    _controller.forward();

    // Chuyển màn hình sau khi hoàn thành animation
    Future.delayed(const Duration(seconds: animationDuration), _navigateToLogin);
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value, // Hiệu ứng mờ dần
              child: Transform.scale(
                scale: _scaleAnimation.value, // Hiệu ứng scale
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 160,
                  height: 160,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
