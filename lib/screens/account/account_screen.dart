import 'package:flutter/material.dart';
import 'saving_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          title: const Text(
            "Account",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 43, 43, 43),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                // Handle notification action
              },
            ),
          ],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: "ACCOUNT"),
              Tab(text: "SAVING"),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),
        body: const TabBarView(
          children: [
            AccountTab(),
            SavingScreen(),
          ],
        ),
      ),
    );
  }
}

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  // Dữ liệu giả
  final List<Map<String, dynamic>> walletList = [
    {
      'walletName': 'Wallet 1',
      'balance': 1000,
      'active': true,
    },
    {
      'walletName': 'Wallet 2',
      'balance': 500,
      'active': false,
    },
    {
      'walletName': 'Wallet 3',
      'balance': 2500,
      'active': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Hiển thị danh sách các ví
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: walletList.length,
              itemBuilder: (context, index) {
                bool isActive = walletList[index]['active'] ?? false;
                return _buildAccountItem(
                  icon: Icons.account_balance_wallet,
                  iconColor:
                      isActive ? Colors.green : Colors.red, // Thay đổi màu icon
                  title: "${walletList[index]['walletName']}",
                  amount: "\$ ${walletList[index]['balance']}",
                  status: isActive ? 'Active' : 'Inactive',
                );
              },
            ),

            const SizedBox(height: 8), // Khoảng cách giữa Cash và Add Wallet

            // Nút thêm Wallet
            Align(
              alignment: Alignment.center, // Căn giữa
              child: ElevatedButton.icon(
                onPressed: () {
                  // Xử lý khi nhấn nút Add Wallet
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => AddWalletScreen()),
                  // );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Wallet"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required String status,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(amount),
            Text(
              status,
              style: TextStyle(
                color: status == 'Active' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Handle more actions
          },
        ),
      ),
    );
  }
}
