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


import 'dart:async';


import 'package:motion_recognizing_game/score_board.dart';

/* For current app state */
enum GameState{
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
  String gameTitle;
  String deviceID;

  GamePage({@required this.nickname, @required this.channel, @required this.gameTitle, @required this.deviceID});
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameState currState = GameState.waiting;
  String keyword = "error";
  //String gameTitle;
  int score = 0;
  int newPoint;
  int currSet = 1;
  int counting;
  String captureImagePath;
  Timer _timer;

  int callFlag = 0;
  bool isResultReceived = false;
  String resultReceived = "";
  bool myCam = true;
  bool capture = true;

  final TextStyle _basicStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontSize: 18
  );



  void completionCount(){
    _timer = Timer(Duration(seconds: 4),
            (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ScoreBoard()));
        }
    );
  }

  Future<String> capturePng() async{
    print("Capture png");
    String path = await NativeScreenshot.takeScreenshot();
    return path;
  }

  void getScore() async {
    poseNet(
        deviceID: widget.deviceID,
        channelNumber: widget.channel,
        imagePath: captureImagePath,
        title: widget.gameTitle,
        round: currSet
    ).then((String s){
      setState(() {
        resultReceived = s;
        isResultReceived = true;
        capture = true;
      });
    });

  }


  void countDown(){
    const oneSec = const Duration(seconds: 1);
    /* initialize value of 'counting' for next time use */
    counting = 7;
    _timer = new Timer.periodic(oneSec,
            (timer) async{
              if(counting == 4){
                setState(() {
                  counting--;
                  currState = GameState.counting;
                });

              }
              else if(counting == 0){
                /* capture a picture and calculate points
                               then send it to server */
                if(capture){
                  setState(() {
                    capture = false;
                  });

                  capturePng().then((String path){
                    print("capture completed");
                    captureImagePath = path;
                    getScore();
                  });
                }
                setState(() {
                  timer.cancel();
                  timer = null;
                  myCam = false;
                  currState = GameState.calculating;
                });
              }
              else {
                setState(() {
                  counting--;
                });
              }
            }
    );
  }

  void resultTimer(){
    counting = 7;
    _timer = new Timer.periodic(Duration(seconds:1),
            (timer) {
              if(counting>0){
                setState((){
                  counting--;
                });
              }
              else{
                setState(() {
                  _timer.cancel();
                  _timer = null;
                  if(currSet + 1 > 7) {
                    completionCount();
                    currState = GameState.completed;
                  }
                  else {
                    myCam = true;
                    currSet++;
                    currState = GameState.waiting;
                  }
                });
              }
            });
  }

  Future<bool> camChange()async{
    bool result = myCam;
    await Future.delayed(Duration(milliseconds: 1));
    return result;
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
                ? FutureBuilder(
                    /* Deciding widget which tell you what state it is now
                         It depends on 'currState' value. */
                    future: conditionalView(),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        return Stack(
                          children: [
                            CallPage(
                                channelName: widget.channel,
                                APP_ID: APP_ID,
                                camera: myCam,
                            ),
                            if(currState !=  GameState.counting && currState != GameState.calculating)
                              background(),
                            snapshot.data,
                            if(currState != GameState.counting)
                              ScoreInfo(),
                          ],
                        );
                        return snapshot.data;
                      }
                      else return Container();
                    },
                  )
                : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),),
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
    if(currState == GameState.waiting){
      return waitingView();
    }
    else if(currState == GameState.ready){
      getKeyword(
          title: widget.gameTitle,
          deviceID: widget.deviceID,
          channelName: widget.channel,
          round: currSet
      ).then((String s){
            List<String> result = s.split("/");
            setState(() {
              if(s == "no"){
                currState = GameState.error;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
                showDialog(context: context, builder: (BuildContext context)=>
                    ErrorDialog(errorMsg: "[get keyword]\nerror",)
                );
              }

              if(result[0] != "no"){
                keyword = result[0];
                countDown();
                callFlag++;
                currState = GameState.keyword;
              }
              else if(result.length == 2 && result[1] == "network"){
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

      if(isResultReceived){
        List<String> result = resultReceived.split("/");
        if(result[0]!= "no"){
          setState(() {
            newPoint = int.parse(result[0]);
            score += newPoint;
            resultTimer();
            isResultReceived = false;
            currState = GameState.result;
            print(currState);
          });
        }
        else{
          setState(() {
            if(_timer.isActive) {
              _timer.cancel();
              _timer = null;
            }
            currState = GameState.error;
          });
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyHomePage()), (route) => false);
          if(result.length == 1)
            showDialog(context: context, builder: (BuildContext context)=>
                ErrorDialog(errorMsg: "[getScore]\nCalculation Error",)
            );
          else if(result.length == 2 && result[1] == "network")
            showDialog(context: context, builder: (BuildContext context)=>
                ErrorDialog(errorMsg: "[getScore]\nConnection Error",)
            );
          else if(result.length == 2)
            showDialog(context: context, builder: (BuildContext context)=>
                ErrorDialog(errorMsg: "[getScore]\nServer error : ${result[1]}",)
            );
        }
      }
      else return Center(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),),
              SizedBox(height: 20),
              Text("calculating..", style: TextStyle(color: Colors.white))
            ],
          )
      );
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




