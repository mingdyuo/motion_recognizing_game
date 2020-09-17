import 'package:flutter/material.dart';


class ScoreData{
  String firstMember;
  String secondMember;
  int score;
  ScoreData({this.firstMember, this.secondMember, this.score});
}

class ScoreBoard extends StatefulWidget {
  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {

  List<ScoreData> data = [
    ScoreData(
      firstMember: "Tom", secondMember: "Jerry",
      score: 330
    ),
    ScoreData(
        firstMember: "Michael", secondMember: "Jackson",
        score: 295
    ),
    ScoreData(
        firstMember: "Tory", secondMember: "Kelly",
        score: 280
    ),
    ScoreData(
        firstMember: "Ariana", secondMember: "Grande",
        score: 255
    ),
  ];

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
            Container(
              alignment: Alignment.topCenter,
              width: _width,
              height: _height * 0.3,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color.fromARGB(255, 217, 56, 41), Color.fromARGB(255, 242, 200, 162)]
                  )
              ),
            ),
            Positioned(
                top: _width * 0.2,
                child: Board()
            )
          ],
        )
      )
    );
  }

  Widget Board(){
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
              child: Table(
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
                    // 
                    for(int i=0;i<data.length;i++)
                      oneRow(data[i], i),
                    for(int i=data.length;i<15;i++)
                      emptyRow(i)
                  ]
              )
          ),
          )

        ],
      )
    );
  }

  TableRow oneRow(ScoreData data, int index){
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



}
