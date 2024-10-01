import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
<<<<<<< Updated upstream
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
=======
import 'package:feat/utils/saveId.dart';

>>>>>>> Stashed changes
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String?> homePosts = []; // 이미지 URL을 저장할 리스트
  Map ProfileImage = {}; // 유저 정보를 저장할 맵
  String? userId;

<<<<<<< Updated upstream
  
  final String userId = "user1"; // 유저 아이디 임시로 저장
=======
  Future<void> loadUserId() async {
    userId = await saveId();
    // userId를 사용하여 추가 작업 수행
    print('User ID: $userId');
  }
>>>>>>> Stashed changes

  Future<void> loadPosts() async {
    final url = Uri.parse('http://172.24.4.212:8080/load/posts/home');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          homePosts = List<String?>.from(
              jsonDecode(response.body)); // JSON 데이터를 리스트로 변환
          print(homePosts);
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadProfile() async {

    final url = Uri.parse('http://172.24.4.212:8080/load/userInfo');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          ProfileImage = Map.from(jsonDecode(response.body)); // JSON 데이터를 리스트로 변환
          print(ProfileImage);
        });
      } else {
        throw Exception('Failed to load profile image');
      }
    } catch (e) {
      print('Error: $e');
    }
  } // 프로필 사진 불러오는 함수 (서버)

  @override
  void initState() {
    super.initState();
    loadPosts(); // 페이지가 생성될 때 데이터 로드
    loadProfile();
    loadUserId();
  }

  @override
  Widget build(BuildContext context)  {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
                icon: Icon(Icons.notifications_none, size: size.height * 0.035),
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
                  height: size.height * 0.045,  // 원형을 위한 height
                  width: size.height * 0.045,   // height와 동일한 width로 설정
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,  // 원형을 보장
                  ),
                  child: ClipOval(
                    child: ProfileImage['profile'] != null && ProfileImage['profile'].isNotEmpty
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
      body: ColoredBox(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(size.width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Music Name',
                      style: TextStyle(
                          fontSize: size.width * 0.04,
                          height: size.height * 0.0035)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                          height: size.height * 0.06,
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(size.width * 0.03), color: Color(0xff3f3f3f),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xff000000).withOpacity(0.25),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: Offset(0, 4) // changes position of shadow
                              ),
                            ],
                          )
                      ),
                      Center(child: Text('SoundWave'))
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.6,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.8),
                itemCount: homePosts.length,
                itemBuilder: (context, index) {
                  final imageUrl = homePosts[index];
                  return Container(
                    margin: EdgeInsets.only(left: 15,right: 30), // 좌우 여백 설정
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
                    child: ClipRRect(  // 경계에 맞게 자르기
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                            : Center(child: Text('No Image'))
                      ),
                    ),
                  );
                },
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color(0xff3f3f3f),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff000000).withOpacity(0.25),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: Offset(0, 4) // changes position of shadow
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(size.width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'calender');
                            },
                            icon: Icon(Icons.date_range, color: Colors.white)),
                        SizedBox(
                          width: size.width * 0.2,
                          height: size.height * 0.075,
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'friendpage');
                            },
                            icon: Icon(Icons.group, color: Colors.white))
                      ],
                    )),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Color(0xff3f3f3f),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xff000000).withOpacity(0.25),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 4) // changes position of shadow
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, 'camera');
                  },
                  child: Container(
                    width: size.width * 0.275,
                    height: size.width * 0.275,
                    decoration: BoxDecoration(
                      color: Color(0xff3f3f3f),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(width: size.width * 0.015, color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff000000).withOpacity(0.25),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: Offset(0, 4) // changes position of shadow
                        ),
                      ],
                    ),
                    child: Icon(Icons.add,
                        color: Colors.white, size: size.width * 0.12)
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


/*
class SoundWaveform extends StatefulWidget {
  const SoundWaveform({super.key});

  @override
  State<SoundWaveform> createState() => _SoundWaveformState();
}

class _SoundWaveformState extends State<SoundWaveform> with TickerProviderStateMixin {
  late AnimationController controller;
  final int count = 30; // Number of bars
  final double minHeight = 10.0; // Minimum bar height
  final double maxHeight = 50.0; // Maximum bar height
  List<double> amplitudes = List.filled(30, 10.0); // Initial waveform heights
  AudioPlayer _audioPlayer = AudioPlayer();
  Random random = Random();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Animation speed
    )..repeat();

    startAudio(); // Start audio playback
  }

  @override
  void dispose() {
    controller.dispose();
    _audioPlayer.dispose(); // Dispose of audio player resources
    super.dispose();
  }

  // Start audio playback and visualization
  Future<void> startAudio() async {
    // Set the audio player mode to low latency for quick start and stop
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Start playing the audio file from assets
    int result = await _audioPlayer.play('assets/your_audio_file.mp3', isLocal: true);

    if (result == 1) {
      setState(() {
        isPlaying = true;
      });
    }

    // Listen to the audio player's position stream to update the waveform
    _audioPlayer.onAudioPositionChanged.listen((duration) {
      if (isPlaying) {
        setState(() {
          // Randomly update bar heights
          amplitudes = List.generate(count, (i) => minHeight + random.nextDouble() * (maxHeight - minHeight));
        });
      }
    });

    // Handle when the audio is finished playing
    _audioPlayer.onPlayerCompletion.listen((_) {
      setState(() {
        isPlaying = false;
        _audioPlayer.stop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (c, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            double height = amplitudes[i]; // Set random height
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: i == (count - 1) ? EdgeInsets.zero : const EdgeInsets.only(right: 5),
              height: height,
              width: 6, // Bar width
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6 + 0.4 * controller.value), // Change color dynamically
                borderRadius: BorderRadius.circular(9999),
              ),
            );
          }),
        );
      },
    );
  }
} */