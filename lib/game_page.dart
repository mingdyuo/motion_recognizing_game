import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motion_recognizing_game/call.dart';
import 'package:motion_recognizing_game/configs/agora_configs.dart';
import 'package:motion_recognizing_game/dialog.dart';
import 'package:motion_recognizing_game/main.dart';
import 'package:motion_recognizing_game/posenet.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import './interface/interface_game_info.dart';

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'dart:async';


import 'package:motion_recognizing_game/score_board.dart';

/* For current app state */
enum GameState{
  finding,
  waiting,
  ready,
  keyword,
  counting,
  calculating,
  result,
  completed,
  error
}


void logError(String code, String message)
=> print('Error: $code\nError Message: $message');

class GamePage extends StatefulWidget {
  final String nickname;
  String channel;

  GamePage({@required this.nickname, @required this.channel});
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameState currState = GameState.finding;
  String keyword = "no";
  String deviceID;
  String gameTitle;
  int score = 0;
  int newPoint;
  int currSet = 1;
  int counting;
  Timer _timer;


  bool myCam = true;
  bool capture = false;

  final TextStyle _basicStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontSize: 18
  );

  Future<String> getDeviceID() async{
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

    if (!mounted) return "temp";
    return deviceData;
  }

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

    if (!mounted) return "";
    deviceID = deviceData;
  }

  void completionCount(){
    _timer = Timer(Duration(seconds: 4),
            (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ScoreBoard()));
        }
    );
  }

  Future<void> capturePng() async{
    print("******Capture png");
    NativeScreenshot.takeScreenshot()
        .then((String imagePath){
          poseNet(
              deviceID: deviceID,
              channelNumber: widget.channel,
              imagePath: imagePath
          );
        });
  }

  void countDown(){
    const oneSec = const Duration(seconds: 1);
    /* initialize value of 'counting' for next time use */
    counting = 7;
    _timer = new Timer.periodic(oneSec,
            (timer) =>setState((){
                if(counting == 4){
                  counting --;
                  currState = GameState.counting;
                }
                else if(counting == 0){
                  /* capture a picture and calculate points
                               then send it to server */
                  capturePng();
                  timer.cancel();
                  timer = null;
                  myCam = false;
                  currState = GameState.calculating;
                }
                else {
                  counting--;
                }

            })

    );
  }

  void resultTimer(){
    _timer = new Timer(Duration(seconds: 4),
            (){
          setState(() {
            _timer.cancel();
            _timer = null;
            if(currSet + 1 > 7) {
              completionCount();
              currState = GameState.completed;
            }
            else {
              currSet++;
              currState = GameState.waiting;
            }
            myCam = true;
          });
        }
    );
  }

  void initState(){
    super.initState();
    setDeviceID();
  }

  void dispose(){
    if(_timer != null) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Scaffold(
        resizeToAvoidBottomInset : false,
        body: Center(
            child: currState!=GameState.error
                ? Stack(
              children: [
                CallPage(
                    channelName: widget.channel,
                    APP_ID: APP_ID,
                    camera: myCam
                ),

                if(currState !=  GameState.counting && currState != GameState.calculating)
                  background(),

                FutureBuilder(
                  /* Deciding widget which tell you what state it is now
                   It depends on 'currState' value. */
                  future: conditionalView(),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return snapshot.data;
                    }
                    else return Container();
                  },
                ),
                if(currState != GameState.counting)
                  ScoreInfo(),
              ],
            ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),),
        )
    );
  }

  Widget background(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(170, 0, 0, 0),
              Color.fromARGB(25, 0, 0, 0),
            ]
        ),
      ),
    );
  }

  Future<Widget> conditionalView() async {
    if(currState==GameState.finding){
      findPartner(
          nickname: widget.nickname,
          device: deviceID==null?await getDeviceID():deviceID)
          .then((value) {
            List<String> result = value.split("/");
            setState(() {
              print("********************value is [$value]");
              print("******************** [${result[0]}], [${result[1]}]");

              if(result[0]!="no") {
                // replace current channel name with new value
                gameTitle = result[0];
                widget.channel = result[1];
                currState = GameState.waiting;
              }
              if(result[1] == "network"){
                currState = GameState.error;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
                showDialog(context: context, builder: (BuildContext context)=>
                    ErrorDialog(errorMsg: "[find partner]\nConnection Error",)
                );
              }
              else if(result[0] == "no"){
                currState = GameState.error;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
                showDialog(context: context, builder: (BuildContext context)=>
                    ErrorDialog(errorMsg: "[find partner]\nServer error : ${result[1]}",)
                );
              }
            });
        });

      return findingView();
    }
    else if(currState == GameState.waiting){
      return waitingView();
    }
    else if(currState == GameState.ready){
      keyword = await getKeyword(
          title: gameTitle,
          deviceID: deviceID,
          channelName: widget.channel,
          round: currSet
      );

      List<String> result = keyword.split("/");

      setState(() {
        if(result[0] != "no"){
          keyword = result[0];
          countDown();
          currState = GameState.keyword;
        }
        if(result.length == 2 && result[1] == "network"){
          currState = GameState.error;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
          showDialog(context: context, builder: (BuildContext context)=>
              ErrorDialog(errorMsg: "[get keyword]\nConnection Error",)
          );
        }
        else if(result.length == 2){
          currState = GameState.error;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
          showDialog(context: context, builder: (BuildContext context)=>
              ErrorDialog(errorMsg: "[get keyword]\nServer error : ${result[1]}",)
          );
        }
      });



      return Center(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),),
              SizedBox(height: 20),
              Text("Waiting all ready..", style: TextStyle(color: Colors.white))
            ],
          )
      );
    }
    else if(currState == GameState.keyword){
      return keywordView();
    }
    else if(currState == GameState.counting){
      return countingView();
    }
    else if(currState == GameState.calculating){
      // get if score calculation is completed
      String rawResult = await getScore(
          nickname: widget.nickname,
          channelName: widget.channel,
          round: currSet
      );
      List<String> result = rawResult.split("/");
      if(result[0]!= "no" && mounted){
        setState(() {
          newPoint = int.parse(result[0]);
          score += newPoint;
          resultTimer();
          currState = GameState.result;
        });
      }
      if(result.length == 2 && result[1] == "network"){
        setState(() {currState = GameState.error;});
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
        showDialog(context: context, builder: (BuildContext context)=>
            ErrorDialog(errorMsg: "[getScore]\nConnection Error",)
        );
      }
      else if(result.length == 2){
        setState(() {currState = GameState.error;});
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
        showDialog(context: context, builder: (BuildContext context)=>
            ErrorDialog(errorMsg: "[getScore]\nServer error : ${result[1]}",)
        );
      }
      return Container();
    }
    else if(currState == GameState.result){
      return ResultView(score: newPoint);
    }
    else if(currState == GameState.completed){
      return CompletedView();
    }

    return Container();
  }

  Widget ScoreInfo(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    double _topPadding = MediaQuery.of(context).padding.top;
    return Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: _topPadding + 15, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "SCORE : ${score}",
                style: _basicStyle
            ),
            Text(
                "STAGE ${currSet} / 7",
                style: _basicStyle
            )
          ],
        )
    );
  }

  Widget CompletedView(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    double _topPadding = MediaQuery.of(context).padding.top;
    return Center(
      child: Container(
          alignment: Alignment.center,
          child: Text(
              "Game Completed",
              textAlign: TextAlign.center,
              style: _basicStyle.copyWith(fontSize: 40)
          )
      ),
    );
  }

  Widget keywordView(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    double _topPadding = MediaQuery.of(context).padding.top;
    return Center(
      child: Container(
          alignment: Alignment.center,
          child: Text(
              keyword,
              textAlign: TextAlign.center,
              style: _basicStyle.copyWith(fontSize: 40)
          )
      ),
    );
  }

  Widget findingView(){

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),),
            SizedBox(height: 20),
            Text(
                "finding other player...",
                style: _basicStyle.copyWith(fontSize: 14)
            )
          ],
        )
    );
  }

  Widget countingView(){
    if(counting > 0)
      return Center(
          child: Text(
              "${counting}",
              style: _basicStyle.copyWith(fontSize: 120)
          )
      );
    else return Container();
  }

  Widget waitingView(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    double _topPadding = MediaQuery.of(context).padding.top;

    return Container(
        width: _width,
        height: _height,
        child: Center(
            child: InkWell(
                onTap: (){
                  if(mounted)
                    setState(() {
                      currState = GameState.ready;
                    });
                },
                splashColor: Color.fromARGB(255, 255, 255, 255),
                child: Container(
                  //width: _width * 0.6,
                  //height: _height * 0.12,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      color: Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6.0,
                          color: Colors.black.withOpacity(.5),
                          offset: Offset(5.0, 6.0),
                        ),
                      ]
                  ),
                  child: Text(
                      "READY",
                      style: _basicStyle.copyWith(fontSize: 25, color: Colors.deepPurple)
                  ),
                )
            )
        )
    );
  }
}

class ResultView extends StatefulWidget {
  int score;
  ResultView({this.score});
  @override
  _ResultViewState createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final List<String> result = [
    "Perfect !",
    "Great !",
    "Nice !",
    "Cool !"
  ];

  int resultIndex;

  final TextStyle _resultStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontSize: 30
  );

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    double _topPadding = MediaQuery.of(context).padding.top;

    if(widget.score > 80) resultIndex = 0;
    else if(widget.score > 70) resultIndex = 1;
    else if(widget.score > 60) resultIndex = 2;
    else resultIndex = 3;

    return Container(
        width: _width,
        height: _height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              child: Image.asset(
                  "assets/images/hanabi.gif",
                  fit: BoxFit.cover
              ),
            ),
            Text(
                result[resultIndex],
                style: _resultStyle
            )
          ],
        )
    );
  }
}




