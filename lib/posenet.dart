import 'package:motion_recognizing_game/interface/interface_game_info.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
Future<String> loadModel() async {
  String res = await Tflite.loadModel(
    model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
  );
  return res;
}


Future<String> poseNet({String deviceID, String channelNumber, String imagePath}) async {
  String isSuccess = await loadModel();

  if(isSuccess!="success"){
    return "no/posnet";
  }
  print(imagePath);
 // int startTime = new DateTime.now().millisecondsSinceEpoch;
  print("before recog ==============");
  var recognitions = await Tflite.runPoseNetOnImage(
    path: imagePath,
    numResults: 1,
  );

  if(recognitions.isEmpty){

  }

  print("after recog ==============");
//  int endTime = new DateTime.now().millisecondsSinceEpoch;
//   print("Inference took ${endTime - startTime}ms");
  print(recognitions);
  var result = (recognitions.first)["keypoints"];


  print("this is result +==========================");
  print(result); // String serverResult = await sendModeling(result);
  //return serverResult;
  var model = [];
  for(int i=0;i<=16;i++){
    model.add(result[i]);
  }
//  print("indexing int==========");
//  print(result[0]);
//  print("indexing string==========");
//  print(result['0']);

  String response = await sendModeling(deviceID, channelNumber, model);

  final dir = Directory(imagePath);
  dir.deleteSync(recursive: true);

  return "no";
  return response;
  // image 제거하는 코드 삽입
}