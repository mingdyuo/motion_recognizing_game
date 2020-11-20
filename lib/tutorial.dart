import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final controller = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(height: 16),
          PageView(
              controller: controller,
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Container(
                  width: _width,
                  height: _height,
                  child: Image.asset("assets/images/tutorial_main_1.png"),
                ),
                Container(
                  width: _width,
                  height: _height,
                  child: Image.asset("assets/images/tutorial_main_2.png"),
                )
              ]
          ),
          SizedBox(height: 16),
          Positioned(
            bottom: _height * 0.05,
            child: SmoothPageIndicator(
              controller: controller,
              count: 2,
              effect: JumpingDotEffect(),
            ),
          )

        ],
      )
    );
  }
}
