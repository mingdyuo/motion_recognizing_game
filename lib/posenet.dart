import 'package:motion_recognizing_game/interface/interface_game_info.dart';
import 'package:tflite/tflite.dart';

Future<String> loadModel() async {
  String res = await Tflite.loadModel(
    model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
  );
  return res;
}

Future poseNet({String deviceID, String channelNumber, String imagePath}) async {
  String model = await loadModel();
  print("posnet +==========================");
  int startTime = new DateTime.now().millisecondsSinceEpoch;
  var recognitions = await Tflite.runPoseNetOnImage(
    path: imagePath,
    numResults: 2,
  );
  int endTime = new DateTime.now().millisecondsSinceEpoch;
  // print("Inference took ${endTime - startTime}ms");

  Map<int, dynamic> result = recognitions[0]['keypoints'];
  print("this is result +==========================");
  print(result); // String serverResult = await sendModeling(result);
  //return serverResult;
  String response = await sendModeling(deviceID, channelNumber, result);
  return response;
  // image 제거하는 코드 삽입
}