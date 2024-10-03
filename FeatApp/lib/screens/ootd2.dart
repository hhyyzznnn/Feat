import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // 추가된 부분

class ootdHomePage extends StatefulWidget {
  ootdHomePage({super.key, this.year, this.month, this.day});

  var year;
  var month;
  var day;

  @override
  State<ootdHomePage> createState() => _ootdHomePageState();
}

class _ootdHomePageState extends State<ootdHomePage> {
  Map ProfileImage = {};
  Map Posts = {};
  String? userId;

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // 유저 아이디 불러오기

    if (userId != null) {
      print('User ID: $userId');
      await loadProfile();
      await loadPosts();
    } else {
      print('User ID not found');
    }
  }

  String formattedDate() {
    return '${widget.year}-${widget.month}-${widget.day}';
  }

  Future<void> loadPosts() async {
    final url = Uri.parse('http://192.168.116.212:8080/load/post/bydate');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "date": formattedDate()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          Posts = Map.from(jsonDecode(response.body)); // JSON 데이터를 리스트로 변환
          print(Posts);
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadProfile() async {
    final url = Uri.parse('http://192.168.116.212:8080/load/userInfo');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          ProfileImage =
              Map.from(jsonDecode(response.body)); // JSON 데이터를 리스트로 변환
          print(ProfileImage);
        });
      } else {
        throw Exception('Failed to load profile image');
      }
    } catch (e) {
      print('Error2: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = Posts['post'];
    final size = MediaQuery.of(context).size;

    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.05),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Text('Feat.',
                style: TextStyle(
                    fontSize: size.height * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3F3F3F))),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    Navigator.pushNamed(context, 'alarm');
                  },
                  icon:
                  Icon(Icons.notifications_none, size: size.height * 0.035),
                  color: Color(0xff3F3F3F),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: size.width * 0.025),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'profile');
                  },
                  borderRadius: BorderRadius.circular(size.height * 0.03),
                  child: Container(
                    height: size.height * 0.045, // 원형을 위한 height
                    width: size.height * 0.045, // height와 동일한 width로 설정
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, // 원형을 보장
                    ),
                    child: ClipOval(
                      child: ProfileImage['profile'] != null &&
                          ProfileImage['profile'].isNotEmpty
                          ? Image.network(
                        ProfileImage['profile'],
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.person,
                        size: size.height * 0.035,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        body: ootdBody(
            year: widget.year,
            month: widget.month,
            day: widget.day,
            url: imageUrl,
            musicUrl: Posts['music']), // 추가된 부분
      ),
    );
  }
}

class ootdBody extends StatefulWidget {
  ootdBody({super.key, this.year, this.month, this.day, this.url, this.musicUrl});

  var year;
  var month;
  var day;
  var url;
  var musicUrl;

  @override
  _ootdBodyState createState() => _ootdBodyState();
}

class _ootdBodyState extends State<ootdBody> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.musicUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(widget.musicUrl);
      _controller = YoutubePlayerController(
        initialVideoId: videoId ?? '',
        flags: YoutubePlayerFlags(
          autoPlay: true, // 자동 재생
          mute: false, // 음소거 설정
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_controller == null) {
      return CircularProgressIndicator(); // 초기화가 안된 경우 대체 UI
    }
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(27, 10, 0, 10),
                  child: Text('${widget.year}. ${widget.month}. ${widget.day}',
                      style: TextStyle(fontSize: 22))),
              Spacer()
            ],
          ),
          Container(
            width: size.width * 0.8,
            height: size.height * 0.7,
            margin: EdgeInsets.only(left: 15, right: 30, bottom: 10), // 좌우 여백 설정
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // 모서리를 둥글게 설정
              boxShadow: [
                BoxShadow(
                  color: Color(0xff000000).withOpacity(0.25),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              // 경계에 맞게 자르기
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: widget.musicUrl != null
                    ? YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                )
                    : Center(child: Text('No Video')),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xffebebeb),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff000000).withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(0, 4), // changes position of shadow
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                width: 200,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                        Text('Music Name', style: TextStyle(fontSize: 22))),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('0000', style: TextStyle(fontSize: 15))),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}