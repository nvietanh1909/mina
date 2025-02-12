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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CALENDAR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Trả ngày về trang trước
              Navigator.of(context).pop(_displayFormat.format(_selectedDate));
            },
            child: const Text(
              'Choose',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateFormat.format(_selectedDate),
                  style: const TextStyle(fontSize: 20),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _selectDate(context, -1);
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    IconButton(
                      onPressed: () {
                        _selectDate(context, 1);
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
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
        ],
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
