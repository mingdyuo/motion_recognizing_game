import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motion_recognizing_game/dialog.dart';
import 'package:motion_recognizing_game/game_page.dart';
import 'package:motion_recognizing_game/interface/interface_game_info.dart';
import 'package:motion_recognizing_game/score_board.dart';
import 'package:motion_recognizing_game/tutorial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';


import './configs/agora_configs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Motion Recognizing Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /* Text controller is used in TextField that makes you can enter nickname in the field */
  final TextEditingController _nicknameController = TextEditingController();
  /* Scaffold key is used for recognizing exact page in which we will show snackbar message. */
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String deviceID;

  Future<void> setDeviceID() async{
    String deviceData;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = iosInfo.utsname.machine;
      }
    } on PlatformException {
      print("device id get error");
    }

    if (!mounted) return "temporary";
    deviceID = deviceData;
  }

  void initState(){
    super.initState();
    setDeviceID();
  }


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return GestureDetector(
      onTap : ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset : false,
        key: _scaffoldKey,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
                alignment: Alignment.topCenter,
                width: _width,
                child: Image.asset(
                    "assets/images/wave2.png",
                    width: _width,
                    fit: BoxFit.fitWidth
                )
            ),
            Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: _height * 0.35),
                      child: NicknameBox(),
                    ),
                    Padding(
                        padding: EdgeInsets.only(bottom: _height * 0.1),
                        child: _buttons()
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: _height * 0.02,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => Tutorial()
                  )
                  );
                },
                child: Container(
                    color: Colors.transparent,
                    child: Text(
                        "How To Play",
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        )
                    )
                ),
              )
            )

          ],
        ),
      )
    );
  }

  Container NicknameBox(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Container(
      width: _width * 0.8,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      height: _height * 0.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromARGB(255, 238, 119, 133),
            Color.fromARGB(255, 219, 133, 165),
            Color.fromARGB(255, 200, 130, 180)
          ]
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 6.0,
            color: Colors.black.withOpacity(.2),
            offset: Offset(5.0, 6.0),
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                  "Enter a nickname in the game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "AppleSDGothicNeo",
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 18
                  )
              ),
            )
          ),
          Container(
            width: _width * 0.7,
            height: _height * 0.1,
            padding: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: Colors.white
            ),
            child: Center(
              child: TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: "Your Nickname",
                  hintStyle: TextStyle(
                    fontFamily: "AppleSDGothicNeo",
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(205, 140, 140, 120),
                    fontSize: 15,
                  ),
                  border: InputBorder.none
                ),
                cursorColor: Colors.pink,
              )
            )
          )
        ],
      )
    );
  }

  Widget _buttons(){
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: ()async{
              /* Check if user entered nickname in the text field */
              if(_nicknameController.text.isEmpty){
                _scaffoldKey.currentState.showSnackBar(
                    SnackBar(content: Text("Enter your nickname for this game."))
                );
              }
              else{
                  await _handleCameraAndMic();
                  showDialog(context: context, builder:(context)
                    => Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 238, 119, 133))
                    ))
                  );
                  String rawResult = await findPartner(
                                            nickname: _nicknameController.text,
                                            device: deviceID);
                  List<String> result = rawResult.split("/");
                 Navigator.of(context).pop();
                  if(result[0]!="no"){
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => GamePage(
                          deviceID: deviceID,
                          nickname: _nicknameController.text,
                          gameTitle: result[0],
                          channel: result[1],
                        )
                    ));
                  }
                  else{
                    Navigator.of(context).pop();
                    if(result.length == 1)
                      showDialog(context: context, builder: (BuildContext context)=>
                          ErrorDialog(errorMsg: "[find partner]\nError",)
                      );
                    else if(result[1] == "network")
                      showDialog(context: context, builder: (BuildContext context)=>
                          ErrorDialog(errorMsg: "[find partner]\nConnection Error",)
                      );

                    else
                      showDialog(context: context, builder: (BuildContext context)=>
                          ErrorDialog(errorMsg: "[find partner]\nServer error : ${result[1]}")
                      );
                  }
              }
              _nicknameController.clear();
            },
            child: _button("Get Started"),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: (){
              _nicknameController.clear();
              Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context) => ScoreBoard(deviceID : deviceID)
              )
              );
            },
            child: _button("Ranking"),
          ),
        ],
      )
    );
  }
  
  Widget _button(String title){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Container(
      width: _width * 0.55,
      height: _height * 0.08,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Color.fromARGB(255, 250, 250, 250),
        boxShadow: [
          BoxShadow(
            blurRadius: 6.0,
            color: Colors.black.withOpacity(.2),
            offset: Offset(5.0, 6.0),
          ),
        ]
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "AppleSDGothicNeo",
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: Colors.deepPurple
            )
        )
      )
    );
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone, PermissionGroup.storage],
    );
  }

}


