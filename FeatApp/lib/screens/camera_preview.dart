import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'music_rec.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreviewPage extends StatefulWidget {
  final String imagePath;
  final String postUrl;

  PreviewPage({super.key, required this.imagePath, required this.postUrl});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String? userId;
  List<String?> musicList = [];


  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // 유저 아이디 불러오기

    if (userId != null) {
      print('User ID: $userId');
    } else {
      print('User ID not found');
    }
  }

  Future<void> loadPosts(String userId, String postUrl) async {
    final url = Uri.parse('http://192.168.116.212:8080/load/musics');
    String slicedUrl = postUrl.split('?')[0];
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "url": slicedUrl}),
      );

      if (response.statusCode == 200) {
        setState(() {
          musicList = List<String?>.from(
              jsonDecode(response.body)); // JSON 데이터를 리스트로 변환
          print(musicList);
        });
      } else {
        throw Exception('Failed to load posts');
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
    final size = MediaQuery.of(context).size;
    final containerWidth = size.width * 0.92;
    final containerHeight = containerWidth * 16 / 9;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 이미지 프리뷰
          Positioned(
            bottom: size.height * 0.13,
            left: size.width * 0.04,
            right: size.width * 0.04,
            child: Center(
              child: SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.02,
            left: size.width * 0.02,
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  size: size.width * 0.075, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center, // Stack 내에서 모든 위젯을 중앙 정렬
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MusicRecPage(
                      youtubeList: musicList.whereType<String>().toList(),),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    // 원형 버튼으로 만들기
                    backgroundColor: Color(0xff3F3F3F),
                    // 배경색
                    padding: EdgeInsets.zero,
                    // 내부 패딩 없애기
                    side: BorderSide(color: Colors.black, width: 10),
                    // 검정 테두리
                    minimumSize:
                        Size(size.width * 0.3, size.width * 0.3), // 크기 설정
                  ),
                  child: Container(
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // 원형으로 만들기
                    ),
                  ),
                ),
                // 중앙에 + 모양의 SVG 추가
                GestureDetector(
                  onTap: () async { // async 키워드 추가
                    if (userId != null) {
                      await loadPosts(userId!, widget.postUrl); // await를 사용하여 loadPosts가 완료될 때까지 기다림
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicRecPage(
                            youtubeList: musicList.whereType<String>().toList(),
                          ),
                        ),
                      );
                    } else {
                      print('User ID is null. Cannot load posts.');
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/icons/plus.svg',
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
