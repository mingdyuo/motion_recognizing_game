import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tflite/tflite.dart';

class PoseEstimation extends StatefulWidget {
  final File image;

  PoseEstimation(this.image);

  @override
  _PoseEstimationState createState() => _PoseEstimationState();
}

class _PoseEstimationState extends State<PoseEstimation> {
  List _recognitions;

  Future loadModel() async {
    String res = await Tflite.loadModel(
      model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
      // useGpuDelegate: true,
    );
//    print(res);
  }

  Future poseNet(File image) async {
    loadModel();

    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 2,
    );
//    print(recognitions);
    setState(() {
      _recognitions = recognitions;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  void renderKeypoints(){

//    _recognitions.forEach((re) {
//      re['keypoints']
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}