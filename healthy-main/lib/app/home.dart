import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../ble/ble_controller.dart';
import '../components/crud.dart';
import 'dart:async';
import 'package:healthy/app/vitsalsigns/add.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final BLEController bleController = BLEController();
  final Crud crud = Crud();
  int? currentHeartRate;
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    bleController.heartRateStream.listen((heartRate) {
      setState(() {
        currentHeartRate = heartRate;
        print('UI updated with heart rate: $currentHeartRate');
      });
    });
  }

  Future<void> requestPermissions() async {
    var statuses = await [
      Permission.bluetooth,
      Permission.location,
    ].request();
    if (statuses[Permission.bluetooth]!.isGranted && statuses[Permission.location]!.isGranted) {
      print("Permissions granted");
    } else {
      print("Permissions not granted");
    }
  }

  void startScan() {
    setState(() {
      scanResults = [];
    });
    print("Starting scan...");
    bleController.startScan();
    FlutterBlue.instance.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
      print("Scan results: ${scanResults.length} devices found");
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await bleController.connectToDevice(device);
    Navigator.pop(context);
  }

  Future<void> sendDataToServer() async {
    if (currentHeartRate != null) {
      await crud.sendHeartRateData(currentHeartRate!);
    } else {
      print("No heart rate data to send");
    }
  }

  @override
  void dispose() {
    bleController.disconnect();
    bleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Heart Rate Monitor",
          style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.bluetooth),
          hoverColor: Colors.blue,
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BluetoothDevicesScreen(
                  scanResults: scanResults,
                  startScan: startScan,
                  connectToDevice: connectToDevice,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add your logout functionality here
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddVs()));
        },
        child: Icon(
          Icons.add,
        ),
        splashColor: Colors.redAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current BPM: ${currentHeartRate ?? 'N/A'}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: startScan,
            child: Text('Scan for Devices'),
          ),
          ElevatedButton(
            onPressed: sendDataToServer,
            child: Text('Send Heart Rate to Server'),
          ),
          scanResults.isNotEmpty
              ? Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final result = scanResults[index];
                return ListTile(
                  title: Text(result.device.name),
                  subtitle: Text(result.device.id.toString()),
                  onTap: () => connectToDevice(result.device),
                );
              },
            ),
          )
              : Text("No devices found")
        ],
      ),
    );
  }
}

class BluetoothDevicesScreen extends StatelessWidget {
  final List<ScanResult> scanResults;
  final Function startScan;
  final Function(BluetoothDevice) connectToDevice;

  BluetoothDevicesScreen({
    required this.scanResults,
    required this.startScan,
    required this.connectToDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Devices'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              startScan();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (c, index) {
          return ListTile(
            title: Text(scanResults[index].device.name),
            subtitle: Text(scanResults[index].device.id.toString()),
            onTap: () {
              connectToDevice(scanResults[index].device);
            },
          );
        },
      ),
    );
  }
}
