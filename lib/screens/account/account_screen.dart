import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Điều chỉnh chiều cao của AppBar
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              //
            },
          ),
          title: const Text(
            "Account",
            style:
                TextStyle(color: Colors.white), // Đặt màu chữ tiêu đề là trắng
          ),
          backgroundColor: const Color(0xFF424242), // Màu nền của AppBar
          elevation: 0, // Bỏ bóng đổ dưới AppBar
          centerTitle: true, // Căn giữa tiêu đề
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                //
              },
            ),
          ],
          foregroundColor:
              Colors.white, // Màu của các icon trong AppBar (trắng)
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: "ACCOUNT"),
                        Tab(text: "SAVINGS"),
                        Tab(text: "ACCUMULATES"),
                      ],
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Total balance: \$4,299.49",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ExpansionPanelList(
                expandedHeaderPadding: const EdgeInsets.all(0),
                elevation: 0,
                children: [
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: const [
                            Text(
                              "Active (\$4,299.49)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.brown,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Cash",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("\$4,299.49"),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              //
                            },
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpanded,
                    canTapOnHeader: true,
                  ),
                ],
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isExpanded = isExpanded;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
