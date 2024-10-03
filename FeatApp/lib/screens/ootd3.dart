import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:feat/utils/appbar.dart';

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
  YoutubePlayerController? _youtubeController; // Nullable로 변경
  bool _isLoading = true; // 로딩 상태를 추적하는 변수 추가
  String? musicName; // 곡 제목
  String? artistName; // 가수 이름
  String? thumbnail;

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // 유저 아이디 불러오기

    if (userId != null) {
      print('User ID: $userId');
      await loadProfile();
      await loadPosts();
    } else {
      print('User ID not found');
      setState(() {
        _isLoading = false; // 로딩 종료
      });
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
          String? musicUrl = Posts['music']; // 'music' 키의 값 가져오기
          if (musicUrl != null) {
            String videoId = YoutubePlayer.convertUrlToId(musicUrl) ?? '';
            _youtubeController = YoutubePlayerController(
              initialVideoId: videoId,
              flags: YoutubePlayerFlags(
                autoPlay: true,
                mute: false,
                hideControls: false,
              ),
            );
            fetchVideoInfo(videoId); // 곡 제목과 아티스트 정보를 가져오기
          } else {
            throw Exception('musicUrl is empty');
          }
          _isLoading = false; // 로딩 종료
        });
      } else {
        throw Exception('Failed to load profile image');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  Future<void> fetchVideoInfo(String videoId) async {
    final apiKey = 'AIzaSyAOY3BhovlWuoDFvgMs-WajC2sJgVZMpkY';
    final url =
        'https://www.googleapis.com/youtube/v3/videos?id=$videoId&key=$apiKey&part=snippet';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'].isNotEmpty) {
        final snippet = data['items'][0]['snippet'];
        String fullTitle = snippet['title']; // 전체 제목

        // '가수 이름 - 곡 제목' 형식에서 가수와 곡 제목 분리
        if (fullTitle.contains(' - ')) {
          List<String> titleParts = fullTitle.split(' - ');
          artistName = titleParts[0]; // 가수 이름
          musicName = titleParts[1]; // 곡 제목
        } else {
          musicName = fullTitle; // 형식이 맞지 않으면 전체를 곡 제목으로
          artistName = snippet['channelTitle']; // 아티스트 이름을 채널 제목으로 설정
        }

        // 괄호 또는 대괄호로 감싸진 텍스트 제거
        if (musicName != null) {
          musicName = musicName!.replaceAll(RegExp(r'\s*\(.*?\)\s*|\s*\[.*?\]\s*'), '');
        }

        setState(() {
          thumbnail = getThumbnailUrl(videoId);
        });
      }
    } else {
      throw Exception('Failed to load video info');
    }
  }

  String getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
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
  void dispose() {
    _youtubeController?.dispose(); // null 체크 후 dispose 호출
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = Posts['post'];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: buildAppBar(context, ' '),
      body: _isLoading // 로딩 상태에 따라 다른 위젯 표시
          ? Center(child: CircularProgressIndicator())
          : ootdBody(
        year: widget.year,
        month: widget.month,
        day: widget.day,
        url: imageUrl,
        youtubeController: _youtubeController,
        musicName: musicName, // 곡 제목 전달
        artistName: artistName, // 아티스트 이름 전달
        thumbnail: thumbnail,
      ),
    );
  }
}

class ootdBody extends StatelessWidget {
  ootdBody({
    super.key,
    this.year,
    this.month,
    this.day,
    this.url,
    this.youtubeController,
    this.musicName,
    this.artistName,
    this.thumbnail, // 썸네일 URL
  });

  var year;
  var month;
  var day;
  var url;
  final YoutubePlayerController? youtubeController;
  final String? musicName; // 곡 제목
  final String? artistName; // 가수 이름
  final String? thumbnail; // 썸네일 URL


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(27, 10, 0, 5),
                  child: Text('$year. $month. $day',
                      style: TextStyle(fontSize: 22, color: Colors.white))),
              Spacer()
            ],
          ),
          if (youtubeController != null) // 유튜브 플레이어가 있을 때만 표시
            Container(
              width: 0, // 화면 너비로 설정
              height: 0, // 적절한 높이로 설정
              child: YoutubePlayer(
                controller: youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.amber,
                onReady: () {
                  // 자동 재생 설정
                  youtubeController!.play();
                },
              ),
            ),
          Container(
            width: size.width * 0.8,
            height: size.height * 0.7,
            margin: EdgeInsets.only(left: 15, right: 30, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: url != null
                    ? Image.network(
                  url,
                  fit: BoxFit.cover,
                )
                    : Center(child: Text('No Image')),
              ),
            ),
          ),
          Row(
            children: [
              // 썸네일을 표시하는 컨테이너 추가 (null 체크 적용)
              if (thumbnail != null && thumbnail!.isNotEmpty)
                Container(
                  width: 65,
                  height: 65,
                  margin: EdgeInsets.only(left: 30, top: 5),
                  child: ClipOval(
                    child: Image.network(
                      thumbnail!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
              // 썸네일이 없을 때 기본 이미지를 보여주는 부분을 추가
                Container(
                  width: 65,
                  height: 65,
                  margin: EdgeInsets.only(left: 30, top: 5, right: 15),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png', // 기본 이미지 경로 설정
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(
                height: 80,
                width: 200,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(musicName ?? '곡 제목 없음', style: TextStyle(fontSize: 22, color: Colors.white))),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(artistName ?? '가수 이름 없음', style: TextStyle(fontSize: 15, color:Colors.white))),
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