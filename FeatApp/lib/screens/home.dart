import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String?> homePosts = []; // 이미지 URL을 저장할 리스트
  Map ProfileImage = {}; // 프로필 사진을 저장할 맵
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // 유저 아이디 불러오기

    if (userId != null) {
      print('User ID: $userId');
      await loadPosts();
      await loadProfile();
    } else {
      print('User ID not found');
    }
  }

  Future<void> loadPosts() async {
    final url = Uri.parse('http://192.168.116.212:8080/load/posts/home');
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
  } // 이미지 불러오는 함수

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
      print('Error: $e');
    }
  } // 프로필 사진 불러오는 함수 (서버)

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.05),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: ' Feat',
                  style: TextStyle(
                    fontSize: size.height * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: TextStyle(
                    fontSize: size.height * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFC4318), // 원하는 색상으로 변경
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  Navigator.pushNamed(context, 'alarm');
                },
                icon: Icon(Icons.notifications_none, size: size.height * 0.04),
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.03),
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
                        : Icon(Icons.person,
                            size: size.height * 0.04, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: ColoredBox(
        color: Colors.black,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(size.width * 0.035),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(' Music Name',
                      style: TextStyle(
                          fontSize: size.width * 0.04,
                          height: size.height * 0.0035,
                          color: Color(0xFFFC4318))),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                          height: size.height * 0.065,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            border: Border.all(width: 1, color: Colors.white),
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xff000000).withOpacity(0.25),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset:
                                      Offset(0, 4) // changes position of shadow
                                  ),
                            ],
                          )),
                      Center(child: Text('SoundWave')) // _Musicvisualizer()
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
                    margin: EdgeInsets.only(left: 15, right: 30), // 좌우 여백 설정
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
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Center(child: Text('No Image'))),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: size.width * 0.005, color: Colors.black),
                      borderRadius: BorderRadius.circular(40.0),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: Offset(4, 4)),
                      ],
                    ),
                    margin: EdgeInsets.all(size.width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'calender');
                            },
                            icon: Icon(Icons.date_range, color: Colors.white)),
                        SizedBox(
                          width: size.width * 0.2,
                          height: size.height * 0.05,
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
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.25),
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
                      width: size.width * 0.225,
                      height: size.width * 0.225,
                      decoration: BoxDecoration(
                        color: Color(0xFFFC4318),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                            width: size.width * 0.005, color: Colors.black),
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
                          color: Colors.black, size: size.width * 0.12)),
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
class _Musicvisualizer extends StatelessWidget {
  List<int> duration = [
    1000,
    2000,
    1500,
    2500,
    3000,
    2000,
    1500,
    2500,
    1000,
    500,
    1200,
    1800,
    2200,
    3000,
    1700,
    1100,
    2400,
    2900,
    1000,
    500
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: new List<Widget>.generate(20, (index) {
        // 인접한 막대기들의 duration 차이를 줄여 자연스럽게 연결되도록 조정
        int adjustedDuration =
            (duration[index % 20] + duration[(index + 1) % 20]) ~/ 2;
        return VisualComponent(duration: adjustedDuration);
      }),
    );
  }
}

class VisualComponent extends StatefulWidget {
  const VisualComponent({super.key, required this.duration});

  final int duration;

  @override
  State<VisualComponent> createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration), vsync: this);
    final curvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.bounceIn);

    animation = Tween<double>(begin: 5, end: 27.5).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 5),
        width: 4.5,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        height: animation.value);
  }
}
*/

/*class SoundWaveform extends StatefulWidget {
  const SoundWaveform({super.key});

  @override
  State<SoundWaveform> createState() => _SoundWaveformState();
}

class _SoundWaveformState extends State<SoundWaveform>
    with TickerProviderStateMixin {
  late AnimationController controller;
  final List<double> amplitudes = [
    10.0,
    20.0,
    15.0,
    25.0,
    30.0,
    20.0,
    15.0,
    25.0,
    10.0,
    5.0,
    12.0,
    18.0,
    22.0,
    30.0,
    17.0,
    11.0,
    24.0,
    29.0,
    10.0,
    5.0
  ];
  final int count = 20;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (c, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            double height = amplitudes[i];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: i == (count - 1)
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 5),
              height: height,
              width: 6,
              // Bar width
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
              ),
            );
          }),
        );
      },
    );
  }
}*/
