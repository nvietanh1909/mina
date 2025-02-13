import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import 'signup_screen.dart';
import 'package:mina/screens/home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hình ảnh (đẩy lên một chút)
              Transform.translate(
                offset: const Offset(0, -10), // Di chuyển lên 10px
                child: SvgPicture.asset(
                  'assets/icons/otp.svg', // Thay bằng đường dẫn đến hình ảnh của bạn
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
                'Enter 4-digit Code code we have sent to at',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'mina@gmail.com', // Thay bằng email của bạn
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Các ô nhập mã OTP
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: formKey,
                  child: Pinput(
                    length: 6, // Số lượng ô OTP
                    controller: pinController,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    // validator: (value) {
                    //   // Xử lý validate mã OTP
                    // },
                    // onCompleted: (pin) {
                    //   // Xử lý khi nhập đủ mã OTP
                    // },
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
              // Nút "Resend Code"
              TextButton(
                onPressed: () {
                  // Xử lý gửi lại mã OTP
                },
                child: const Text(
                  'Resend Code',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 12),
              // Nút "Verify"
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // Tạo khoảng cách hai bên
                child: SizedBox(
                  width: double.infinity,
                  height: 48, // Tăng chiều cao để dễ bấm hơn
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeTab()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D61E7),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Bo góc mềm mại
                      ),
                      elevation: 6, // Tạo hiệu ứng đổ bóng
                      shadowColor: Colors.blue.withOpacity(0.3), // Màu bóng nhẹ
                    ),
                    child: const Text(
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
    );
  }
}
