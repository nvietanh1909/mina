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
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold), // Đặt màu chữ tiêu đề là trắng
          ),
          backgroundColor:
              const Color.fromARGB(255, 43, 43, 43), // Màu nền của AppBar
          elevation: 0, // Bỏ bóng đổ dưới AppBar
          centerTitle: true, // Căn giữa tiêu đề
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                // Handle notification action
              },
            ),
          ],
          foregroundColor:
              Colors.white, // Màu của các icon trong AppBar (trắng)
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

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Total balance: \$ 4,299.49",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAccountItem(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.brown,
              title: "Cash",
              amount: "\$ 4,299.49",
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
        subtitle: Text(amount),
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
