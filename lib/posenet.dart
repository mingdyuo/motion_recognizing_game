import 'package:motion_recognizing_game/interface/interface_game_info.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
Future<String> loadModel() async {
  String res = await Tflite.loadModel(
    model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
  );
  return res;
}


Future<String> poseNet({String deviceID, String channelNumber, String imagePath, String title, int round}) async {
  String isSuccess = await loadModel();
  if(isSuccess!="success"){
    return "no/posnet";
  }
  var recognitions = await Tflite.runPoseNetOnImage(
    path: imagePath,
    numResults: 1,
  );
  var model = [];
  if(recognitions.isEmpty){
    Map<String, dynamic> temp = Map<String,dynamic>();
    temp['score'] = 0.0;
    temp['part'] = 'nose';
    temp['x'] = 0.0;
    temp['y'] = 0.0;
    for(int i=0;i<=16;i++){
      model.add(temp);
    }
  }
  else{
    var result = (recognitions.first)["keypoints"];
    for(int i=0;i<=16;i++){
      model.add(result[i]);
    }
  }

  String response = await sendModeling(
      deviceID: deviceID,
      channelNumber: channelNumber,
      model: model,
      title: title,
      round: round
  );

  final dir = Directory(imagePath);
  dir.deleteSync(recursive: true);

  return response;
}