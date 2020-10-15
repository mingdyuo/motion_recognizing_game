import 'package:flutter/material.dart';
import 'package:motion_recognizing_game/game_page.dart';
import 'package:motion_recognizing_game/main.dart';

import './interface/interface_score_board.dart';


class ScoreBoard extends StatefulWidget {
  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {

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
                  return Container();
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
          child: Text("${data.firstMember} & ${data.secondMember}", style: tableDetailStyle, textAlign: TextAlign.center,),
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>GamePage()));
            },
            child: _button("게임하기")
          ),
          GestureDetector(
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
              },
              child: _button("메인으로")
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
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 35, right: 35),
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
