import 'package:flutter/material.dart';
// import 'package:healthy/components/crud.dart';
// import 'package:healthy/components/valid.dart';
// import 'package:healthy/main.dart';

import '../../ble/wid.dart';
import '../../components/crud.dart';
import '../../components/customtextform.dart';
import '../../components/valid.dart';
import '../../constant/linkapi.dart';
import '../../main.dart';
import '../home.dart';

class AddVs extends StatefulWidget {
  AddVs({Key? key}): super(key: key);
  @override
  State<AddVs> createState() => _AddVsState();
}
Crud sendHeartRateData = sendHeartRateData;
class _AddVsState extends State<AddVs> with Crud{
  GlobalKey<FormState> formstate =GlobalKey<FormState>();
  // TextEditingController Tempurature =TextEditingController();
  // TextEditingController Glucose =TextEditingController();
  TextEditingController Heartrate =TextEditingController();

  bool isLoading =false;

  addVs()async{
    if(formstate.currentState!.validate()){
      isLoading =true;
      setState((){});
      var response = await postRequest(linkAddData, {
        // "temp":  Tempurature.text,
        // "gluc":  Glucose.text,
        "bmp":   Heartrate.text,
        "id" : sharedPref.getString("id")
      });
      isLoading =false ;
      setState((){});
      if (response!['status']=="success"){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Home()));      }else {

      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Please edit you vital Signs"),
        backgroundColor: Colors.redAccent,

      ),
      body:isLoading ==true?
          Center(child: CircularProgressIndicator()):

      Container(
        padding: EdgeInsets.all(10),
        child: Form(
          key: formstate,
          child: ListView(
              children: [
                // CustTextForm(hint: "Tempurature" ,mycontroller: Tempurature,valid:(val){
                //   return validInput(val!, 1, 5);
                // }, obscureText: null ,),
                // CustTextForm(hint: "Glucose" ,mycontroller:Glucose ,valid:(val){
                //   return validInput(val!, 1, 5);
                //
                // }, obscureText: null ,),
                CustTextForm(hint: "Heartrate" ,mycontroller:Heartrate ,valid:(val){
                  return validInput(val!, 1, 5);

                }, obscureText: null ,),
                Container(height: 20,),
                MaterialButton(onPressed: ()async{
                    await addVs();
                },
                  textColor: Colors.white,
                  color: Colors.redAccent,
                  child:const Text("Addvs"),
                ),

              ],
        ),
        ),
      ),
    );
  }
}