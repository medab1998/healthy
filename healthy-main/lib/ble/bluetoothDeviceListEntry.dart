import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onTap;

  BluetoothDeviceListEntry({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name),
      subtitle: Text(device.id.toString()),
      onTap: onTap,
    );
  }
}
