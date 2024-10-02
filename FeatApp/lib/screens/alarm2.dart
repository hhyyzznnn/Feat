import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:feat/utils/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Map?> Alarms = [{}, {'type': 'newPosts'}, {}];
  String? userId;

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // 유저 아이디 불러오기

    if (userId != null) {
      print('User ID: $userId');
    } else {
      print('User ID not found');
    }
  }

  Future<void> loadAlarms() async {
    final url = Uri.parse('http://192.168.116.212:8080/load/');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          Alarms =
              List<Map?>.from(jsonDecode(response.body)); // JSON 데이터를 리스트로 변환
          print(Alarms);
        });
      } else {
        throw Exception('Failed to load alarms');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context, '알람'),
      body: ListView.builder(
          itemCount: Alarms.length,
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // 그림자 위치
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 15,right: 5),
                    leading: CircleAvatar(
                      backgroundImage:
                          Alarms[index]!['fromUserProfile'] != null &&
                                  Alarms[index]!['fromUserProfile'].isNotEmpty
                              ? NetworkImage(Alarms[index]!['fromUserProfile'])
                              : null,
                      child: Alarms[index]!['fromUserProfile'] == null ||
                              Alarms[index]!['fromUserProfile'].isEmpty
                          ? Icon(Icons.person)
                          : null,
                    ),
                    title: Alarms[index]!['type'] == 'newPosts'
                        ? Text(
                            '${Alarms[index]!['fromUserName']}님이 새 게시물을 작성하였습니다.',
                            style: TextStyle(color: Colors.white, fontSize: 18))
                        : Text(
                            '${Alarms[index]!['fromUserName']}님이 친구 요청을 보냈습니다.',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                    subtitle: Text('${Alarms[index]!['fromUserId']}',
                        style: TextStyle(color: Color(0xFFFC4318), fontSize: 14)),
                    trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.delete_outline, color: Colors.red))));
          }),
    );
  }
}
