import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import './interface_url.dart';

/* Class to save score information for each game.
It has two nicknames in a team and score that the team got. */
class ScoreData{
  String firstMember;
  String secondMember;
  int score;
  ScoreData({this.firstMember, this.secondMember, this.score});
}

/* This list is an example about how to use ScoreData class
List<ScoreData> data = [
  ScoreData(
      firstMember: "Tom", secondMember: "Jerry",
      score: 330
  ),
  ScoreData(
      firstMember: "Michael", secondMember: "Jackson",
      score: 295
  ),
  ScoreData(
      firstMember: "Tory", secondMember: "Kelly",
      score: 280
  ),
  ScoreData(
      firstMember: "Ariana", secondMember: "Grande",
      score: 255
  ),
];
*/

Future<List<ScoreData>> getData() async {
  /* Prepare an empty list */
  List<ScoreData> data = [];

  try {
    final response = await http.get(url_score_board);
    if (response.statusCode == 200) {
      var rawList = jsonDecode(response.body) as List;

      for(var item in rawList){
        ScoreData rawitem = ScoreData();
        rawitem.firstMember = item['firstMember'];
        rawitem.secondMember = item['secondMember'];
        rawitem.score = item['score'];
        data.add(rawitem);
      }
      return data;
    }
    else
      return data;
  } catch(_) {
    return data;
  }
}