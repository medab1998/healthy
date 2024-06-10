import 'dart:developer';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:healthy/components/crud.dart';
import 'package:healthy/components/customtextform.dart';
import 'package:healthy/components/valid.dart';
import 'package:healthy/constant/linkapi.dart';
import 'package:healthy/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:healthy/app/home.dart';

class Login extends StatefulWidget {
  final http.Client httpClient;

  const Login({Key? key, required this.httpClient}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formstate = GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Crud crud = Crud();

  bool isLoading = false;

  login() async {
    if (formstate.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        var response = await crud.postRequest(
            linkLogin, {"email": email.text, "password": password.text});

        setState(() {
          isLoading = false;
        });

        if (response != null) {
          if (response['status'] == "success") {
            log('id is : ${response['data']['id']}');
            await crud.setID(response['data']['id'].toString());
            sharedPref.setString("email", response['data']['email']);
            Navigator.of(context).pushNamedAndRemoveUntil("home", (route) => false);
          } else {
            AwesomeDialog(
                context: context,
                title: "Alert",
                body: Text("Email or Password doesn't exist, please try again"))
              ..show();
          }
        } else {
          AwesomeDialog(
              context: context,
              title: "Error",
              body: Text("No response from server, please try again"))
            ..show();
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        log('Error: $e');  // Log the detailed error
        AwesomeDialog(
            context: context,
            title: "Error",
            body: Text("Connection failed, please try again"))
          ..show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.all(10),
          child: isLoading == true
              ? Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              Form(
                key: formstate,
                child: Column(
                  children: [
                    Image.asset(
                      'images/heart.png',
                      width: 200,
                      height: 200,
                    ),
                    CustTextForm(
                      valid: (val) {
                        return validInput(val!, 3, 60);
                      },
                      mycontroller: email,
                      hint: "email",
                      obscureText: false,
                    ),
                    CustTextForm(
                      valid: (val) {
                        return validInput(val!, 3, 200);
                      },
                      mycontroller: password,
                      hint: "password",
                      obscureText: true,
                    ),
                    MaterialButton(
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 70, vertical: 10),
                      onPressed: () async {
                        await login();
                      },
                      child: Text("Login"),
                    ),
                    Container(height: 10),
                    InkWell(
                      child: Text("Sign Up"),
                      onTap: () {
                        Navigator.of(context).pushNamed("signup");
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
