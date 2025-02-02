import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mina/theme/color.dart';
import 'package:mina/screens/account/account_screen.dart';
import 'package:mina/screens/camera/camera_screen.dart';
import 'package:mina/screens/profile/profile_screen.dart';
import 'package:mina/screens/report/report_screen.dart';
import 'package:mina/screens/home/transaction/transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
      body: Container(
        // Add Container to set background color
        color: Colors.white, // Set the background color to white
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance and Summary Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Your total balance",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF333030),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xFF434343),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "\$ 4,299.49",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    "Income",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                "\$ 5,000.00",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    "Spend",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                "\$ 700.51",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Spending Limit Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Limit for this month",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "\$ 700.51",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 170,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "700.51 / 1,000.00",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Transaction List
                const Text(
                  "Income",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTransactionItem(
                    icon: Icons.payments,
                    title: "Payment received",
                    date: "18 Jun 2022",
                    amount: "+ 5000 \$"),
                const SizedBox(height: 16),
                const Text(
                  "Expense",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTransactionItem(
                    icon: Icons.music_note,
                    title: "Spotify Music",
                    date: "21 Jun 2022",
                    amount: "- 6,99 \$"),
                _buildTransactionItem(
                    icon: Icons.shopping_cart,
                    title: "Amazon prime",
                    date: "21 Jun 2022",
                    amount: "-500,00 \$"),
                _buildTransactionItem(
                    icon: Icons.directions_car,
                    title: "Uber",
                    date: "18 Jun 2022",
                    amount: "-126 \$"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
  }) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Text(amount,
            style: TextStyle(
                color: amount.startsWith("+") ? Colors.green : Colors.red)),
      ],
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AccountScreen(),
    CameraScreen(),
    ReportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          height: 70,
          backgroundColor: AppColors.white,
          activeColor: AppColors.bottomNavIconHover,
          inactiveColor: AppColors.bottomNavIconColor,
          border: const Border(top: BorderSide.none),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Nút khác đẩy xuống dưới
                children: [
                  SvgPicture.asset(
                    'assets/icons/li_home.svg',
                    width: 24,
                    height: 24,
                    color: _currentIndex == 0
                        ? AppColors.bottomNavIconHover
                        : AppColors.bottomNavIconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentIndex == 0
                          ? AppColors.bottomNavIconHover
                          : AppColors.bottomNavIconColor,
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Nút khác đẩy xuống dưới
                children: [
                  SvgPicture.asset(
                    'assets/icons/li_account.svg',
                    width: 24,
                    height: 24,
                    color: _currentIndex == 1
                        ? AppColors.bottomNavIconHover
                        : AppColors.bottomNavIconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentIndex == 1
                          ? AppColors.bottomNavIconHover
                          : AppColors.bottomNavIconColor,
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Camera sát lên trên
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/li_camera.svg',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Nút khác đẩy xuống dưới
                children: [
                  SvgPicture.asset(
                    'assets/icons/li_report.svg',
                    width: 24,
                    height: 24,
                    color: _currentIndex == 3
                        ? AppColors.bottomNavIconHover
                        : AppColors.bottomNavIconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentIndex == 3
                          ? AppColors.bottomNavIconHover
                          : AppColors.bottomNavIconColor,
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Nút khác đẩy xuống dưới
                children: [
                  SvgPicture.asset(
                    'assets/icons/li_profile.svg',
                    width: 24,
                    height: 24,
                    color: _currentIndex == 4
                        ? AppColors.bottomNavIconHover
                        : AppColors.bottomNavIconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentIndex == 4
                          ? AppColors.bottomNavIconHover
                          : AppColors.bottomNavIconColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              _screens[index], // Chồng màn hình hiện tại
              Positioned(
                bottom: 20, // Đặt dấu + ở dưới cùng
                right: 20, // Đặt dấu + ở bên phải
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransactionScreen(
                              currentScreen: HomeTab())),
                    );
                    print("Dấu + đã được nhấn");
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue, // Màu xanh nước biển
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
