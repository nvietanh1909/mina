import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateScreen extends StatefulWidget {
  const DateScreen({Key? key}) : super(key: key);

  @override
  State<DateScreen> createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  DateTime _selectedDate = DateTime.now();
  final _dateFormat = DateFormat('MMMM yyyy');
  final _displayFormat = DateFormat('d MMM yyyy');

  // Refined color palette
  final Color _primaryColor = const Color(0xFF4A6CF7); // Vibrant blue
  final Color _backgroundColor = const Color(0xFFF9FAFF); // Soft light blue
  final Color _textPrimaryColor = const Color(0xFF1D2939); // Deep slate
  final Color _textSecondaryColor = const Color(0xFF667085); // Muted gray
  final Color _accentColor = const Color(0xFFE6EDFF); // Light blue accent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Select Date',
          style: TextStyle(
            color: _textPrimaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_displayFormat.format(_selectedDate));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 4,
                shadowColor: _primaryColor.withOpacity(0.4),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Navigation Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateFormat.format(_selectedDate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    _monthNavButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onPressed: () => _selectDate(context, -1),
                    ),
                    const SizedBox(width: 12),
                    _monthNavButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      onPressed: () => _selectDate(context, 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calendar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: (DateTime value) {
                  setState(() {
                    _selectedDate = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Elegant navigation button
  Widget _monthNavButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _accentColor,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: _textSecondaryColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, int monthOffset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year,
          _selectedDate.month + monthOffset, _selectedDate.day);
    });
  }
}
