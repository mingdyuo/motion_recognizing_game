import 'package:flutter/material.dart';
import 'dart:async';

enum GameState{
  waiting,
  ready,
  keyword,
  counting,
  calculating,
  result,
  completed,
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameState currState = GameState.ready;
  String keyword = "목도리도마뱀";
  int point = 0;
  int currSet = 1;
  int counting = 3;
  bool _ready = false;
  Timer _timer;

  final TextStyle _basicStyle = TextStyle(
    fontFamily: "AppleSDGothicNeo",
    fontWeight: FontWeight.w400,
    color: Colors.white,
    fontSize: 18
  );

  void countDown(){
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec,
            (timer) => setState(
                (){
                  // TODO : check counting is correctly don
                  print("in the func");
                  if(counting == 0){
                    currState = GameState.calculating;
                    print("value is 0");
                    counting --;
                  }
                  if(counting < 0) {
                    print("value under 0");
                    timer.cancel();
                    /* initialize value of 'counting' for next time use */
                    counting = 3;
                  }
                  else {
                    print("subtraction");
                    counting -= 1;
                  }

                }
            ));
  }

  void pointUp(int add){
    setState(() {
      point += add;
    });
  }

  void nextSet(){
    setState(() {
      currSet++;
    });
  }

  void ChangeKeyword(String newKeyword){
    setState(() {
      keyword = newKeyword;
    });
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
            /* Video Call Widget Here */
            Container(
              width: _width,
              height: _height,
              child: Image.asset(
                "assets/images/face_example.png",
                fit: BoxFit.fill
              )
            ),
            /*
            View widget which tell you what state is now
            It depends on 'currState' value.
            */
            conditionalView()
          ],
        )
      )
    );
  }

  Widget conditionalView(){
    if(currState == GameState.waiting){

    }
    else if(currState == GameState.ready){
      return readyView();
    }
    else if(currState == GameState.keyword){
      return keywordView();
    }
    else if(currState == GameState.counting){
      countDown();
      return countingView();
    }
    else if(currState == GameState.calculating){
      return Container();
    }
    else if(currState == GameState.result){

    }
    else if(currState == GameState.completed){

    }
    else return Container();
  }

  Widget keywordView(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    double _topPadding = MediaQuery.of(context).padding.top;
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(top: _topPadding + 15, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${point}점",
                  style: _basicStyle
                ),
                Text(
                  "${currSet}번째/7세트",
                  style: _basicStyle
                )
              ],
            )
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              keyword,
              textAlign: TextAlign.center,
              style: _basicStyle.copyWith(fontSize: 40)
            )
          ),
          SizedBox(height: 50,)
        ],
      )
    );
  }

  Widget countingView(){
    return Center(
      child: Text(
          "${counting}",
          style: _basicStyle.copyWith(fontSize: 120)
      )
    );
  }

  Widget readyView(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    double _topPadding = MediaQuery.of(context).padding.top;

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
        child: Center(
          child: GestureDetector(
              onTap: (){
                setState(() {
                  _ready = true;
                  currState = GameState.counting;
                });
                // TODO : send ready signal to server
              },
              child: Container(
                  width: _width * 0.7,
                  height: _height * 0.15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      color: _ready ? Color.fromARGB(200, 219, 133, 165) : Color.fromARGB(100, 219, 133, 165)
                  ),
                  child: Center(
                    child: Text(
                        "READY",
                        style: _basicStyle.copyWith(fontSize: 40)
                    ),
                  )
              )
          ),
        )
    );
  }


}

