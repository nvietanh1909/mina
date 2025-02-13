import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SavingScreen extends StatelessWidget {
  const SavingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/coin.svg',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 12),
            const Text(
              'You have no saving account!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 2),
            TextButton(
              onPressed: () {
                // Handle "Add saving account" button press
              },
              child: const Text(
                '+ Add saving account',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
