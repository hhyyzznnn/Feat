import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:feat/utils/appbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MusicRecPage extends StatefulWidget {
  final List<String> youtubeList;

  const MusicRecPage({super.key, required this.youtubeList});

  @override
  State<MusicRecPage> createState() => _MusicRecPageState();
}

class _MusicRecPageState extends State<MusicRecPage> {
  late List<String> musicList;
  String? userId;
  late YoutubePlayerController _controller;
  int currentSongIndex = 0;
  bool isPlaying = false;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;

  List<String> videoTitles = [];

  String? currentVideoTitle = '';
  String? currentChannelTitle = '';

  List<Map<String, String>> videoInfos = [];

  @override
  void initState() {
    super.initState();
    loadUserId();
    _initializeMusicList();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // 유저 아이디 불러오기

    if (userId != null) {
      print('User ID: $userId');
    } else {
      print('User ID not found');
    }
  }

  Future<void> _initializePlayer() async {
    _controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(musicList[currentSongIndex])!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: false,
      ),
    );

    _controller.addListener(() {
      // 현재 재생 상태(isPlaying)가 변경된 경우에만 상태 업데이트
      if (_controller.value.isPlaying != isPlaying) {
        setState(() {
          isPlaying = _controller.value.isPlaying;
        });
      }

      // 현재 재생 시간 및 총 재생 시간이 변경된 경우에만 상태 업데이트
      if (_controller.value.position != currentDuration ||
          _controller.metadata.duration != totalDuration) {
        setState(() {
          currentDuration =
              Duration(seconds: _controller.value.position.inSeconds);
          totalDuration =
              Duration(seconds: _controller.metadata.duration.inSeconds);
        });
      }
    });
  }

  Future<Map<String, String>> fetchVideoInfo(String videoId) async {
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
        String artistName = '';
        String songTitle = '';

        // 제목 형식이 '가수 이름 - 곡 제목'일 경우만 처리
        if (fullTitle.contains(' - ')) {
          List<String> titleParts = fullTitle.split(' - ');
          artistName = titleParts[0]; // 가수 이름
          songTitle = titleParts[1]; // 곡 제목

          // 괄호 또는 대괄호로 감싸진 텍스트 제거
          songTitle =
              songTitle.replaceAll(RegExp(r'\s*\(.*?\)\s*|\s*\[.*?\]\s*'), '');
        } else {
          songTitle = fullTitle; // 형식이 맞지 않으면 전체를 곡 제목으로
          // 괄호 또는 대괄호로 감싸진 텍스트 제거
          songTitle =
              songTitle.replaceAll(RegExp(r'\s*\(.*?\)\s*|\s*\[.*?\]\s*'), '');
        }

        return {
          'title': songTitle,
          'channelTitle': artistName, // 가수 이름
        };
      }
    }
    throw Exception('Failed to load video info');
  }

  Future<void> sendUrlToServer(String url) async {
    final serverUrl = Uri.parse('http://192.168.116.212:8080/select/music');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final Map<String, String> data = {
      'music': url,
      'userId': userId!,
      'date': today
    };

    // HTTP POST 요청을 보냅니다.
    final http.Response response = await http.post(
      serverUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 요청 헤더에 Content-Type 지정
      },
      body: jsonEncode(data), // 데이터를 JSON 형식으로 인코딩하여 전송
    );

    // 응답 상태 코드 확인
    if (response.statusCode == 200) {
      print('URL 전송 성공: ${response.body}');
    } else {
      print('URL 전송 실패: ${response.statusCode}');
    }
  }

  Future<void> _initializeMusicList() async {
    musicList = widget.youtubeList;

    if (musicList.isNotEmpty) {
      print('${musicList}');
      await _initializePlayer(); // 플레이어 초기화
      await _fetchAllVideoInfos(); // 비디오 정보 가져오기
    }
  }

  Future<void> _fetchAllVideoInfos() async {
    List<Map<String, String>> fetchedInfos = [];
    for (String url in musicList) {
      String videoId = YoutubePlayer.convertUrlToId(url)!;
      try {
        final videoInfo = await fetchVideoInfo(videoId);
        fetchedInfos.add(videoInfo);
      } catch (e) {
        print('Error fetching video info: $e');
      }
    }
    setState(() {
      videoInfos = fetchedInfos;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playMusic() {
    String? videoId = YoutubePlayer.convertUrlToId(musicList[currentSongIndex]);
    if (videoId != null) {
      _controller.load(videoId);
      setState(() {
        isPlaying = true;
        // 현재 비디오의 제목과 채널 이름 업데이트
      });
    } else {
      print('Invalid video URL');
    }
  }

  void _pauseMusic() {
    _controller.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void _resumeMusic() {
    _controller.play();
    setState(() {
      isPlaying = true;
    });
  }

  void _previousMusic() {
    setState(() {
      if (currentSongIndex > 0) {
        currentSongIndex--;
        _playMusic();
      }
    });
  }

  void _nextMusic() {
    setState(() {
      if (currentSongIndex < musicList.length - 1) {
        currentSongIndex++;
        _playMusic();
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<String> fetchVideoTitle(String videoId) async {
    final apiKey = 'AIzaSyAOY3BhovlWuoDFvgMs-WajC2sJgVZMpkY';
    final url =
        'https://www.googleapis.com/youtube/v3/videos?id=$videoId&key=$apiKey&part=snippet';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'].isNotEmpty) {
        return data['items'][0]['snippet']['title']; // 영상 제목 반환
      }
    }
    throw Exception('Failed to load video title');
  }

  String getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: buildAppBar(context, ''),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Colors.black,
            Color(0xFF3F3F3F), // 끝 색상 (예: 살구색)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 5),
              width: size.width * 0.875,
              height: size.height * 0.1,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.175,
                    height: size.width * 0.175,
                    margin: EdgeInsets.only(left: 12.5, right: 25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey,
                      image: DecorationImage(
                        image: NetworkImage(getThumbnailUrl(
                            YoutubePlayer.convertUrlToId(
                                musicList[currentSongIndex])!)),
                        fit: BoxFit.cover, // 이미지를 맞춤 설정
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text:
                                  '${videoInfos.isNotEmpty ? videoInfos[currentSongIndex]['title'] : 'Loading...'}\n',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.5)),
                          TextSpan(
                            text: videoInfos.isNotEmpty
                                ? videoInfos[currentSongIndex]['channelTitle']
                                : 'Artist Name',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 20,
              height: 30,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 0,
              height: 0,
              color: Colors.black,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.amber,
                onReady: () {},
              ),
            ),
            SizedBox(
              width: size.width * 0.875,
              height: size.height * 0.425,
              child: ListView.builder(
                itemCount: musicList.length,
                itemBuilder: (context, index) {
                  String videoId =
                      YoutubePlayer.convertUrlToId(musicList[index])!;
                  return Container(
                    width: size.width * 0.9,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(13),
                    decoration: ShapeDecoration(
                      color: Color(0xFF3F3F3F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRect(
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 0.79,
                            heightFactor: 0.79,
                            child: Container(
                              width: size.width * 0.225,
                              height: size.width * 0.225,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(getThumbnailUrl(videoId)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 25),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${videoInfos.isNotEmpty ? videoInfos[index]['title'] : 'Loading...'}\n', // 여기서 index를 사용
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: videoInfos.isNotEmpty
                                      ? videoInfos[index]
                                          ['channelTitle'] // 여기서 index를 사용
                                      : 'Artist Name',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: size.width * 0.9,
              height: size.height * 0.05,
              child: Column(
                children: [
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        double newPosition =
                            (details.localPosition.dx / (size.width * 0.9))
                                .clamp(0.0, 1.0);
                        Duration seekPosition = Duration(
                            seconds: (newPosition * totalDuration.inSeconds)
                                .toInt());
                        _controller.seekTo(seekPosition);
                        currentDuration = seekPosition;
                      });
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: size.width * 0.9,
                          height: size.height * 0.0105,
                          decoration: BoxDecoration(
                            color: Color(0xffD9D9D9),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: (1 -
                                  currentDuration.inSeconds /
                                      totalDuration.inSeconds) *
                              size.width *
                              0.9,
                          child: Container(
                            height: size.height * 0.011,
                            decoration: BoxDecoration(
                              color: Color(0xfFC4318).withOpacity(1),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(currentDuration),
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Spacer(),
                      Text(
                        formatDuration(totalDuration),
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String currentVideoUrl = musicList[currentSongIndex];
                await sendUrlToServer(currentVideoUrl);
                Navigator.pushNamed(context, 'home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFC4318), // 버튼 색상
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Colors.grey.withOpacity(0.5), // 그림자 색상
                elevation: 10, // 그림자의 높이 (숫자가 클수록 더 진하고 큰 그림자)
              ),
              child: Text(
                'Upload',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:
                      Icon(Icons.skip_previous, size: 60, color: Colors.white),
                  onPressed: _previousMusic,
                ),
                SizedBox(width: 15),
                IconButton(
                  icon: isPlaying
                      ? Icon(Icons.pause, size: 85, color: Colors.white)
                      : Icon(Icons.play_arrow, size: 85, color: Colors.white),
                  onPressed: isPlaying ? _pauseMusic : _resumeMusic,
                ),
                SizedBox(width: 15),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 60, color: Colors.white),
                  onPressed: _nextMusic,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
