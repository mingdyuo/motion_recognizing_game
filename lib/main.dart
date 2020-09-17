import 'package:flutter/material.dart';
import 'package:motion_recognizing_game/score_board.dart';

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
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return GestureDetector(
      onTap : ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                  alignment: Alignment.topCenter,
                  width: _width,
                  child: Image.asset(
                      "assets/images/wave2.png",
                      fit: BoxFit.fitWidth
                  )
              ),
              Positioned(
                top: _height * 0.35,
                child: NicknameBox()
              ),
              Positioned(
                bottom: _height * 0.1,
                child: Buttons()
              )
            ],
          ),
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
          Text(
            "닉네임을 입력하세요.",
            style: TextStyle(
              fontFamily: "AppleSDGothicNeo",
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 18
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

  Widget Buttons(){
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              _nicknameController.clear();
            },
            child: Button("입장하기"),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: (){
              _nicknameController.clear();
              Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context) => ScoreBoard()
              )
              );
            },
            child: Button("랭킹보기"),
          )
        ],
      )
    );
  }
  
  Widget Button(String title){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Container(
      width: _width * 0.55,
      height: _height * 0.08,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Color.fromARGB(255, 248, 236, 201),

//        gradient: LinearGradient(
//          begin: Alignment.centerLeft,
//          end: Alignment.centerRight,
//          colors: [Color.fromARGB(255, 248, 236, 201), Colors.white]
//        )
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "AppleSDGothicNeo",
              fontWeight: FontWeight.w400,
//              color: Colors.white,
              fontSize: 18
            )
        )
      )
    );
  }
}


