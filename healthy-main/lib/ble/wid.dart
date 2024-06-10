import 'package:flutter/material.dart';

class HeartRateWidget extends StatelessWidget {
  final int heartRate;

  HeartRateWidget({required this.heartRate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Heart Rate',
            style: TextStyle(fontSize: 24),
          ),
          Text(
            '$heartRate bpm',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
