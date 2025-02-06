import 'package:flutter/material.dart';
import 'package:mina/screens/auth/login_screen.dart';
import 'package:mina/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // Use PreferredSize to remove AppBar
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: SingleChildScrollView(
        // Để tránh tràn màn hình khi nội dung dài
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin người dùng
            Padding(
              padding: const EdgeInsets.only(
                  top: 34.0), // Thêm khoảng cách phía trên
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    // Thay thế bằng hình ảnh người dùng (nếu có)
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Viet Anh Nguyen',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text('mina@gmail.com'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30), // Đẩy nội dung xuống dưới

            // Các mục cài đặt
            _buildSettingRow(
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            _buildSettingRow(
              title: 'Language',
              trailing: const Text('EN >'),
            ),
            _buildSettingRow(
              title: 'Dark mode',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
            ),
            _buildSettingRow(
              title: 'Currency',
              trailing: const Text('\$ >'),
            ),
            _buildSettingRow(
              title: 'Change Password',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            _buildSettingRow(
              title: 'Log out',
              trailing: const Icon(Icons.logout),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo một hàng cài đặt
  Widget _buildSettingRow(
      {required String title, required Widget trailing, Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            trailing,
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại xác nhận khi bấm logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Gọi logout từ AuthProvider
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();

                // Điều hướng về màn hình login
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
