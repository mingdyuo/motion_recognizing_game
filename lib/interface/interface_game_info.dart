import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import './interface_url.dart';
import 'package:dio/dio.dart';


//
//Future<String> nicknameCheck({String nickname, String device})async{
//  //return "yes";
//  FormData formData = FormData.fromMap({
//    'nickname' : nickname,
//    'deviceID' : device,
//  });
//  try {
//    var response = await Dio().post(
//        url_find,
//        data: formData
//    );
//    if(response.statusCode == 200){
//      return response.data;
//    }
//    else return "no/${response.statusCode}";
//  } catch(_) {
//    return "no/network";
//  }
//}

Future<String> findPartner({String nickname, String device}) async {
  // send ready signal and get channel name from server
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
      return response.data;
    }
    else return "no/${response.statusCode}";
  } catch(_) {
    return "no/network";
  }
}

Future<String> getKeyword({String deviceID, String channelName, int round}) async{
  //return "abc";
  FormData formData = FormData.fromMap({
    'deviceID' : deviceID,
    'channelNumber' : channelName,
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

Future<String> sendModeling() async {
   // send modeling data to server

  FormData formData = FormData.fromMap({

  });
  try {
    var response = await Dio().post(
        url_modeling,
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

Future<String> getScore({String nickname, String channelName, int round}) async {
  // get score from server
  // return "no";
  FormData formData = FormData.fromMap({
    'nickname' : nickname,
    'channelName' : channelName,
    'round' : round
  });
  try {
    var response = await Dio().post(
        url_score,
        data: formData
    );
    if(response.statusCode == 200){
      return "${response.data}";
    }
    else return "no/${response.statusCode}";
  } catch(_) {
    return "no/network";
  }
}