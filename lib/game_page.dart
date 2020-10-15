import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motion_recognizing_game/call.dart';
import 'package:motion_recognizing_game/configs/agora_configs.dart';
import './interface/interface_game_info.dart';

import 'dart:async';

import 'package:motion_recognizing_game/score_board.dart';

enum GameState{
  finding,
  waiting,
  ready,
  keyword,
  counting,
  calculating,
  result,
  completed,
}

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
  int score = 0;
  int newPoint;
  int currSet = 1;
  int counting;
  Timer _timer;

  bool myCam = true;

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

  void countDown(){
    const oneSec = const Duration(seconds: 1);
    counting = 7;
    _timer = new Timer.periodic(oneSec,
            (timer) => setState(
                (){
                  if(counting == 4){
                    counting --;
                    currState = GameState.counting;
                  }
                  else if(counting == 0){
                    currState = GameState.calculating;
                    timer.cancel();
                    timer = null;
                    /* initialize value of 'counting' for next time use */
                    myCam = false;
                    // TODO : send signal & picture to server
                  }
                  else {
                    counting--;
                  }
                }
            ));
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
      body: Center(
        child: Stack(
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
              ScoreInfo()
          ],
        )
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
      findPartner(nickname: widget.nickname).then((value) {
        print("result : $value");
        setState(() {
          if(value!="no") {
            // replace current channel name with new value
            widget.channel = value;
            currState = GameState.waiting;
          }
        });

      });
      return Center(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),),
              SizedBox(height: 20),
              Text("상대를 찾는 중..", style: TextStyle(color: Colors.white))
            ],
          )
      );
    }
    else if(currState == GameState.waiting){
      return waitingView();
    }
    else if(currState == GameState.ready){
      keyword = await getKeyword(
          nickname: widget.nickname,
          channelName: widget.channel,
          round: currSet
      );
      if(keyword != "no" && mounted){
        setState(() {
          countDown();
          currState = GameState.keyword;
        });
      }
      return Center(
        child : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),),
            SizedBox(height: 20),
            Text("상대를 기다리는 중..", style: TextStyle(color: Colors.white))
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
      newPoint = await getScore(
        nickname: widget.nickname,
        channelName: widget.channel,
        round: currSet
      );
      if (newPoint > -1){
        score += newPoint;
        if(mounted)
          setState(() {
            resultTimer();
            currState = GameState.result;
          });
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
                "${score}점",
                style: _basicStyle
            ),
            Text(
                "${currSet}번째/7세트",
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
            Text(
                "상대방 찾는 중...",
                style: _basicStyle.copyWith(fontSize: 120)
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





