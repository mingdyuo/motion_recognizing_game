import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final controller = PageController(viewportFraction: 1);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: new LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 0xFF, 0xA6, 0x9E),
                Color.fromARGB(255, 0x86, 0x16, 0x57)
              ],
            ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView(
                controller: controller,
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  ImagePage(
                    assetName: "assets/images/tutorial_main_1.png",
                  ),
                  ImagePage(
                    assetName: "assets/images/tutorial_main_2.png",
                  ),


                ]
            ),
            Positioned(
              bottom : _height * 0.05,
              child: SmoothPageIndicator(
                controller: controller,
                count: 2,
                effect: JumpingDotEffect(
                  activeDotColor: Color.fromARGB(255,0xEE, 0xC0, 0xC6)
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}



class ImagePage extends StatelessWidget{
  String assetName;
  ImagePage({this.assetName});
  @override
  Widget build(BuildContext context){
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  spreadRadius: 5,
                  color: Colors.black.withOpacity(.2),
                  offset: Offset(3.0, 3.0),
                ),
              ]
          ),
          child: Image.asset(
              assetName,
              fit: BoxFit.contain
          ),
        )
    );
  }
}