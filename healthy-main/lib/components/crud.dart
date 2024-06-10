import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/linkapi.dart';

String _basicAuth = 'Basic ${base64Encode(utf8.encode('iotbd'))}';

Map<String, String> myheaders = {'authorization': _basicAuth};

class Crud {
  Future<String?> getID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? myID = sharedPreferences.getString('id');
    print("Retrieved user ID: $myID"); // Debugging statement
    return myID;
  }

  Future<void> setID(String newID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('id', newID);
    print("User ID set to: $newID"); // Debugging statement
  }

  Future<Map<String, dynamic>?> postRequest(String url, Map<String, dynamic> data) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(data);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error Catch $e");
    }
    return null;
  }

  Future<void> sendHeartRateData(int heartRate) async {
    String? userId = await getID();
    if (userId != null) {
      var response = await postRequest(linkAddData, {
        "bmp": heartRate.toString(),
        "id": userId,
      });
      if (response != null && response['status'] == "success") {
        print("Heart rate data sent successfully");
      } else {
        print("Failed to send heart rate data");
      }
    } else {
      print("User ID not found");
    }
  }
}
