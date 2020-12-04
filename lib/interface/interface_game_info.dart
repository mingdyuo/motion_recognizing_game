import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import './interface_url.dart';
import 'package:dio/dio.dart';



Future<String> findPartner({String nickname, String device}) async {
  // return "nasdf/2";
  FormData formData = FormData.fromMap({
    'nickname' : nickname,
    'deviceID' : device,
  });
  try {
    var response = await Dio().post(
        url_find,
        data: formData
    );
    if(response.statusCode == 200){

      if(response.data['title']=="no"){
        return "no/Matching error";
      }

      String result = '${response.data['title']}/${response.data['channel_number']}';
      return result;
    }
    else return "no/${response.statusCode}";
  } catch(_) {
    return "no/network";
  }
}

Future<String> getKeyword({String title, String deviceID, String channelName, int round}) async{
  //return "keykey";
  FormData formData = FormData.fromMap({
    'title' : title,
    'deviceID' : deviceID,
    'channel_number' : channelName,
  });
  try {
    var response = await Dio().post(
        url_keyword,
        data: formData
    );
    if(response.statusCode == 200){
      return response.data;
    }
    else return "no/${response.statusCode}";
  } catch(_) {
    return "no/network";
  }
}

Future<String> sendModeling({String deviceID, String channelNumber, String title, int round, var model}) async {
   // send modeling data to server

  String jsonModel = json.encode(model);
  FormData formData = FormData.fromMap({
    'deviceID': deviceID,
    "channel_number": channelNumber,
    'title': title,
    'result':jsonModel,
    'round': round.toString()
  });
  try {
    var response = await Dio().post(
        url_main+'score/',
        data: formData
    );
    print(response.data);
    if(response.statusCode == 200){
      return response.data;
    }
    else return "no/${response.statusCode}";
  } catch(_) {
    return "no/network";
  }
}
