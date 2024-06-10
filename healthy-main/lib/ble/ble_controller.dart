import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import '../components/crud.dart';
import '../constant/linkapi.dart';
import '../main.dart';

class BLEController {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? heartRateCharacteristic;
  StreamSubscription? scanSubscription;
  String? deviceMacAddress;

  final StreamController<int> _heartRateController = StreamController<int>.broadcast();

  Stream<int> get heartRateStream => _heartRateController.stream;

  void startScan() {
    scanSubscription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.id.id == 'fd:76:5e:5e:90:fb') {
        print('Smartwatch found with MAC: ${scanResult.device.id.id}');
        stopScan();
        connectToDevice(scanResult.device);
      }
    });
  }

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    connectedDevice = device;
    deviceMacAddress = device.id.id; // Store the MAC address
    print('Connected to device with MAC: $deviceMacAddress');
    discoverServices();
  }

  Future<void> discoverServices() async {
    if (connectedDevice == null) return;

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.uuid.toString() == '00002a37-0000-1000-8000-00805f9b34fb') {
          heartRateCharacteristic = characteristic;
          print('Found heart rate characteristic');
          startListeningToHeartRate();
        }
      });
    });
  }

  void startListeningToHeartRate() {
    heartRateCharacteristic?.value.listen((value) {
      if (value.isNotEmpty) {
        int heartRate = value[1];
        print('Received heart rate: $heartRate');
        _heartRateController.add(heartRate);
        sendDataToServer("",heartRate.toString());
      }
    });

    heartRateCharacteristic?.setNotifyValue(true);
  }

  void disconnect() {
    connectedDevice?.disconnect();
    connectedDevice = null;
    heartRateCharacteristic = null;
  }

  void dispose() {
    _heartRateController.close();
  }
}
postRequest(String url, Map data) async {
  try {
    var response = await http.post(
        Uri.parse(url),
        body: data,
        headers: myheaders
    );
    print(data);
    if (response.statusCode == 200) {
      var responsebody = jsonDecode(response.body);
      return responsebody;
    } else {
      print("Error ${response.statusCode}");
    }
  } catch (e) {
    print("Error Catch $e");
  }
}
sendDataToServer(String temp, String bmp) async {
  var response = await postRequest(
      linkAddData, {
    // "temp": temp,
    // "gluc": "",
    "bmp": bmp,
    "id": sharedPref.getString("id")
  });

  if (response != null && response['status'] == "success") {
    print("sent successfully");
  } else {
    print("not sent");
  }
}