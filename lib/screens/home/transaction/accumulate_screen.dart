import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mina/screens/home/date/date_screen.dart';
import 'package:mina/screens/home/category/category_screen.dart';

class AccumulateScreen extends StatefulWidget {
  const AccumulateScreen({super.key});

  @override
  State<AccumulateScreen> createState() => _AccumulateScreenState();
}

class _AccumulateScreenState extends State<AccumulateScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  String date = DateFormat('d MMM yyyy').format(DateTime.now());
  String toAccount = 'CHOOSE';
  String fromAccount = 'Default';
  String repeating = 'No';

  @override
  void initState() {
    super.initState();
    amountController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAmountField(),
              const SizedBox(height: 20),
              buildSelectableField('Date', date, () async {
                final selectedDate = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DateScreen()),
                );
                if (selectedDate != null) {
                  setState(() {
                    date = selectedDate;
                  });
                }
              }),
              buildSelectableField('To Account', toAccount, () async {
                // Handle account selection
              }),
              buildSelectableField('From Account', fromAccount, () {
                // Handle account selection
              }),
              buildSelectableField('Repeating', repeating, () {
                // Handle repeating selection
              }),
              buildNotesField('Notes', notesController),
              const SizedBox(height: 20),

              // Save Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _saveAccumulate();
                    },
                    child: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 32),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAccumulate() {
    // Handle save logic
    print(
        'Accumulate saved: ${amountController.text}, $date, $toAccount, $fromAccount, $repeating, ${notesController.text}');
  }

  Widget buildAmountField() {
    return Center(
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget buildSelectableField(String label, String value, Function() onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400)),
                Row(
                  children: [
                    Text(value, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1.4,
          color: const Color(0xFFE1E1E1),
        ),
      ],
    );
  }

  Widget buildNotesField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            hintText: 'Enter notes...',
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
