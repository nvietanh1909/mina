import 'package:flutter/material.dart';
import 'package:mina/screens/auth/login_screen.dart';
import 'package:mina/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mina/services/api_service.dart';
import 'package:mina/model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await AuthService().getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Lỗi khi lấy profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị loading hoặc dữ liệu
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Hiển thị vòng xoay loading
                : Padding(
                    padding: const EdgeInsets.only(top: 34.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user?.name ?? 'N/A',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(_user?.email ?? 'N/A'),
                          ],
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 30),

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
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();
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
