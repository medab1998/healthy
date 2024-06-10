// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'ble_controller.dart';
//
// class BluetoothPage extends StatefulWidget {
//   @override
//   _BluetoothPageState createState() => _BluetoothPageState();
// }
//
// class _BluetoothPageState extends State<BluetoothPage> {
//   final BLEController bleController = BLEController();
//
//   @override
//   void initState() {
//     super.initState();
//     bleController.startScan();
//   }
//
//   @override
//   void dispose() {
//     bleController.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth'),
//       ),
//       body: Center(
//         child: Text('Scanning for devices...'),
//       ),
//     );
//   }
// }
