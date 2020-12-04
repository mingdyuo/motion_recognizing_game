import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final controller = PageController(viewportFraction: 1);

  List<Widget> pages = [
    PhoneImage(assetName: 'assets/images/tutorial_main_1.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_main_2.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_2.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_3.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_4.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_5_1.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_5_2.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_5_3.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_6.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_7.jpg',),
    PhoneImage(assetName: 'assets/images/tutorial_8.jpg',),
  ];

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
                children: pages
            ),
            Positioned(
              bottom : _height * 0.05,
              child: SmoothPageIndicator(
                controller: controller,
                count: pages.length,
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


class PhoneImage extends StatelessWidget {
  String assetName;
  PhoneImage({this.assetName});
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _width = _size.width;
    double _height = _size.height;
    return Container(
      width: _width * 0.75,
      height: _width * 0.75 * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                assetName,
                width: _width * 0.7,
              ),
            ),
          ),
          Image.asset(
              'assets/images/frame.png',
              width: _width * 0.75,
            fit: BoxFit.fill
          )
        ],
      ),
    );
  }
}
