import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../components/crud.dart';
import '../constant/linkapi.dart';
import '../main.dart';


class BluetoothDevicesScreen extends StatefulWidget {
  final List<ScanResult> scannedDevices;
  final Function(BluetoothDevice) onDeviceTap;
  final Function startScan;

  BluetoothDevicesScreen({
    required this.scannedDevices,
    required this.onDeviceTap,
    required this.startScan,
  });

  @override
  _BluetoothDevicesScreenState createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  Timer? _timer;
  int? currentHeartRate; // Store the current heart rate

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      widget.startScan();
    });
    // Start the timer to send data every 3 seconds
    _startSendingData();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  void _startSendingData() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (currentHeartRate != null) {
        sendDataToServer(currentHeartRate!);
      }
    });
  }

  void sendDataToServer(int heartRate) async {
    Crud crud = Crud();
    String? userId = await crud.getID();
    if (userId != null) {
      var response = await crud.postRequest(linkAddData, {
        "bmp": heartRate.toString(),
        "id": userId,
      });
      if (response != null && response['status'] == "success") {
        print("Sent successfully");
      } else {
        print("Not sent");
      }
    } else {
      print("User ID not found");
    }
  }

  void updateHeartRate(int heartRate) {
    setState(() {
      currentHeartRate = heartRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Devices'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              widget.startScan();
            },
          ),
        ],
      ),
      body: widget.scannedDevices.isEmpty
          ? Center(child: Text('No devices found'))
          : ListView.builder(
        itemCount: widget.scannedDevices.length,
        itemBuilder: (context, index) {
          final result = widget.scannedDevices[index];
          final device = result.device;

          return BluetoothDeviceListEntry(
            result: result,
            onTap: () {
              widget.onDeviceTap(device);
              Navigator.pop(context);
              // Example: You should replace this with your logic to start reading heart rate data
              startReadingHeartRate(device);
            },
          );
        },
      ),
    );
  }

  void startReadingHeartRate(BluetoothDevice device) {
    // Example logic: Replace with your actual implementation to read heart rate from the device
    device.connect().then((_) {
      // Discover services and characteristics
      device.discoverServices().then((services) {
        services.forEach((service) {
          service.characteristics.forEach((characteristic) {
            if (characteristic.properties.notify) {
              characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                // Update the heart rate value
                int heartRate = value[1]; // Example: Adjust based on your data format
                updateHeartRate(heartRate);
              });
            }
          });
        });
      });
    });
  }
}

class BluetoothDeviceListEntry extends StatelessWidget {
  final ScanResult result;
  final GestureTapCallback onTap;

  BluetoothDeviceListEntry({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = result.device;
    final rssi = result.rssi;

    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.devices),
      title: Text(
          '${device.name.isNotEmpty ? device.name : "Unknown device"} (${device.id})'),
      subtitle: Text('RSSI: $rssi'),
    );
  }
}
