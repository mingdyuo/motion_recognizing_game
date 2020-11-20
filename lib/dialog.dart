
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  String errorMsg;
  ErrorDialog({this.errorMsg});

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
                  errorMsg,
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
                height: 45,
                child: GestureDetector(
                    onTap: ()=>Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.only(right: 50, bottom: 10 ),
                      alignment: Alignment.centerRight,
                      color: Colors.transparent,
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontFamily: "AppleSDGothicNeo",
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 139, 139),
                          fontSize: 15,
                        ),
                      ),
                    )
                )
            ),
          ],
        )
    );
  }
}