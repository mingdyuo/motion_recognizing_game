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
  GameState currState = GameState.waiting;
  String keyword = "no";
  int point = 0;
  int currSet = 1;
  int counting;
  Timer _timer;

  final TextStyle _basicStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontSize: 18
  );

  getScore() async {
    int result = 3;
    // TODO
    // get score from server
    // if not calculated yet, return -1
    return result;
  }

  Future<String> getKeyword() async{
    // TODO
    // get keyword from server
    String keywordFromServer = "keyword";

    return keywordFromServer;
  }

  void countDown(){
    const oneSec = const Duration(seconds: 1);
    counting = 7;
    _timer = new Timer.periodic(oneSec,
            (timer) => setState(
                (){
                  print(counting);
                  if(counting == 4){
                    counting --;
                    currState = GameState.counting;
                  }
                  else if(counting == 0){
                    currState = GameState.calculating;
                    timer.cancel();
                    timer = null;
                    /* initialize value of 'counting' for next time use */
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
            if(currSet > 7) currState = GameState.completed;
            else currState = GameState.waiting;
             _timer.cancel();
             _timer = null;
          });
        }
    );
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
            FutureBuilder(
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

  Future<Widget> conditionalView() async {
    if(currState == GameState.waiting){
      return waitingView();
    }
    else if(currState == GameState.ready){
      keyword = await getKeyword();
      if(keyword != "no"){
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
            Text("상대 찾는 중..", style: TextStyle(color: Colors.white))
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
      int result = await getScore();
      if(result > -1){
        currSet++;
        setState(() {
          currState = GameState.result;
          resultTimer();
        });
      }
      return Container();
    }
    else if(currState == GameState.result){
      return ResultView(score: 34);
    }
    else if(currState == GameState.completed){

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
                "${point}점",
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
          child: InkWell(
            onTap: (){
              setState(() {
                currState = GameState.ready;
              });

              // TODO : send ready signal to server
            },
              splashColor: Color.fromARGB(255, 255, 255, 255),
            child: Container(
                width: _width * 0.6,
                height: _height * 0.12,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(55),
                    color: Color.fromARGB(100, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6.0,
                        color: Colors.black.withOpacity(.5),
                        offset: Offset(5.0, 6.0),
                      ),
                    ]
                ),
                child: Center(
                  child: Text(
                      "READY",
                      style: _basicStyle.copyWith(fontSize: 30)
                  ),
                )
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





