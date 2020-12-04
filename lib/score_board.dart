import 'package:flutter/material.dart';
import 'package:motion_recognizing_game/dialog.dart';
import 'package:motion_recognizing_game/game_page.dart';
import 'package:motion_recognizing_game/interface/interface_game_info.dart';
import 'package:motion_recognizing_game/main.dart';
import 'package:permission_handler/permission_handler.dart';
import './interface/interface_score_board.dart';
import 'dart:math';

class ScoreBoard extends StatefulWidget {
  String deviceID;
  ScoreBoard({@required this.deviceID});
  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {

  final _scoreBoardKey = GlobalKey<ScaffoldState>();

  final tableTitleStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w500,
      color: Colors.black,
      fontSize: 16,
      height: 1.8
  );

  final tableDetailStyle = TextStyle(
      fontFamily: "AppleSDGothicNeo",
      fontWeight: FontWeight.w300,
      color: Colors.black,
      fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Scaffold(
      key: _scoreBoardKey,
        resizeToAvoidBottomInset : false,
      body: Container(
        width: _width,
        height: _height,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // gradient box below the score board
            Container(
              alignment: Alignment.topCenter,
              width: _width,
              height: _height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft, // start point of the gradation
                  end: Alignment.centerRight, // end point of the gradation
                  colors: [
                    Color.fromARGB(255, 217, 56, 41),  // start color of the gradation
                    Color.fromARGB(255, 242, 200, 162) // end color of the gradation
                  ]
                )
              ),
            ),
            Positioned(
                top: _height * 0.15,
                child: _board()
            ),
            Positioned(
              bottom: _height * 0.03,
              child: _buttons()
            )
          ],
        )
      )
    );
  }

  Widget _board(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;

    return Container(
      height: _height * 0.7,
      width: _width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 6.0,
            color: Colors.black.withOpacity(.2),
            offset: Offset(0.0, 6.0),
          ),
        ]
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20, top: 23),
            alignment: Alignment.centerLeft,
            child: Text(
              "Score",
                style: TextStyle(
                  fontFamily: "AppleSDGothicNeo",
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 20
                )
            )
          ),
          Flexible( // Take all the rest space of BoardBox
            child: SingleChildScrollView(
              // Board Data would be exceed the space we prepared
              // "SingleChildScrollView" Widget help put all score data
              // by showing them through scrolling
              physics: BouncingScrollPhysics(),
              child: FutureBuilder(
                future: getData(),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {
                          0: FractionColumnWidth(.25),
                          1: FractionColumnWidth(.5),
                          2: FractionColumnWidth(.25),
                        },
                        children: [
                          // all elements here should be "TableRow" widget
                          // which has a row with multiple element
                          TableRow(
                            // Title of each Column
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 231, 230, 230)
                              ),
                              children: [
                                Text("Rank", style: tableTitleStyle, textAlign: TextAlign.center,),
                                Text("Nicknames", style: tableTitleStyle, textAlign: TextAlign.center,),
                                Text("score", style: tableTitleStyle, textAlign: TextAlign.center,),
                              ]
                          ),
                          // create rows according to the "ScoreData"
                          for(int i=0;i<snapshot.data.length;i++)
                            dataRow(snapshot.data[i], i),
                          // if rows are few, make some more rows to fill rest of the board
                          for(int i=snapshot.data.length;i<15;i++)
                            emptyRow(i)
                        ]
                    );
                  }
                  return Container(
                    padding: EdgeInsets.all(5),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 139, 139),),)
                  );
                }
              )
            ),
          ),
          SizedBox(height: 25,)
        ],
      )
    );
  }

  TableRow dataRow(ScoreData data, int index){
    return TableRow(
      decoration: BoxDecoration(
        color: (index % 2 == 1)
          ? Color.fromARGB(255, 242, 242, 242) : Colors.white
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(2.5),
          child: Text("${index + 1}", style: tableDetailStyle, textAlign: TextAlign.center,),
        ),
        Padding(
          padding: EdgeInsets.all(2.5),
          child: Text("${data.members}", style: tableDetailStyle, textAlign: TextAlign.center,),
        ),
        Padding(
            padding: EdgeInsets.all(2.5),
            child: Text("${data.score}", style: tableDetailStyle, textAlign: TextAlign.center,),
        ),
      ]
    );
  }

  TableRow emptyRow(int index){
    return TableRow(
      decoration: BoxDecoration(
          color: (index % 2 == 1)
              ? Color.fromARGB(255, 242, 242, 242) : Colors.white
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(2.5),
            child: Text(" ", style: tableDetailStyle),
        ),
        Padding(
          padding: EdgeInsets.all(2.5),
          child: Text(" ", style: tableDetailStyle),
        ),
        Padding(
          padding: EdgeInsets.all(2.5),
          child: Text(" ", style: tableDetailStyle),
        ),
      ]
    );
  }

  Widget _buttons(){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;

    return Container(
      width: _width * 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              showDialog(context: context, builder:(BuildContext context)
                => NicknameDialog(widget.deviceID)
              );
            },
            child: _button("Get Started")
          ),
          GestureDetector(
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
              },
              child: _button("Back to Main")
          )
        ],
      )
    );
  }

  Widget _button(String title){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Container(
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Color.fromARGB(255, 255, 139, 139),
          boxShadow: [
            BoxShadow(
              blurRadius: 6.0,
              color: Colors.black.withOpacity(.2),
              offset: Offset(0.0, 6.0),
            ),
          ]
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "AppleSDGothicNeo",
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontSize: 18
          )
        )
    );
  }
}


class NicknameDialog extends StatelessWidget {
  TextEditingController _nicknameController = TextEditingController();
  String deviceID;
  // GlobalKey<ScaffoldState> _key;
  NicknameDialog(this.deviceID);

  @override
  Widget build(BuildContext context){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return AlertDialog(
        titlePadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0))),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 15, top: 20),
              child: Text(
                  "Enter a nickname in the game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "AppleSDGothicNeo",
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 18
                  )
              ),
            ),
            Container(
                width: _width * 0.7,
                padding: EdgeInsets.only(left: 20, right: 20),
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(30, 150, 100, 70)
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
            ),
            Container(
                height: 45,
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Color.fromARGB(255, 180, 180, 180),
                            width: 0.3
                        )
                    )
                ),
                child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex:1,
                          child: GestureDetector(
                              onTap: ()=>Navigator.of(context).pop(),
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontFamily: "AppleSDGothicNeo",
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(205, 140, 140, 140),
                                    fontSize: 15,
                                  ),
                                ),
                              )
                          ),
                        ),
                        Container(
                          width: 0.3,
                          color: Color.fromARGB(255, 180, 180, 180),
                        ),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                                onTap: ()async{
                                  await _handleCameraAndMic();
                                  if(_nicknameController.text.isEmpty){
                                    // _key.currentState.showSnackBar(
                                    //   SnackBar(content: Text("Enter your nickname for this game."))
                                    // );
                                  }
                                  else {
                                    await _handleCameraAndMic();
                                    showDialog(context: context, builder: (context) =>
                                        Center(child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                Color.fromARGB(255, 238, 119, 133))
                                        ))
                                    );
                                    String rawResult = await findPartner(
                                        nickname: _nicknameController.text,
                                        device: deviceID);
                                    List<String> result = rawResult.split("/");
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    if (result[0] != "no") {
                                      //Navigator.of(context).pop();
                                      Navigator.push(
                                          context, MaterialPageRoute(
                                          builder: (context) =>
                                              GamePage(
                                                deviceID: deviceID,
                                                nickname: _nicknameController.text,
                                                gameTitle: result[0],
                                                channel: result[1],
                                              )
                                      ));
                                    }
                                    else {
                                      if (result.length == 1)
                                        showDialog(context: context, builder: (BuildContext context) =>
                                            ErrorDialog(errorMsg: "[find partner]\nError",)
                                        );
                                      else if (result[1] == "network")
                                        showDialog(context: context, builder: (BuildContext context) =>
                                            ErrorDialog(errorMsg: "[find partner]\nConnection Error",)
                                        );
                                      else
                                        showDialog(context: context, builder: (BuildContext context) =>
                                            ErrorDialog(
                                                errorMsg: "[find partner]\nServer error : ${result[1]}")
                                        );
                                    }
                                    _nicknameController.clear();
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.transparent,
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                      fontFamily: "AppleSDGothicNeo",
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromARGB(255, 255, 139, 139),
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                            )
                        )
                      ],
                    )
                )
            ),
          ],
        )
    );
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone, PermissionGroup.storage],
    );
  }
}