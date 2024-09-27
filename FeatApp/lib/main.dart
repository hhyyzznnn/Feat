import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'screens/alarm.dart';
import 'screens/camera2.dart';
import 'screens/calender.dart';
import 'screens/friendpage.dart';
import 'screens/music_rec.dart';
import 'screens/ootd.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(FeatApp(firstCamera: firstCamera));
}

class FeatApp extends StatelessWidget {
  final CameraDescription? firstCamera;

  const FeatApp({super.key, this.firstCamera});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    return userId == null; // '=='를 '!='로 수정해야 함. 코딩 위해서 임의로 바꿔놓음
  } // 로그인 여부 확인

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomePage();
          } else {
            return SignInPage();
          }
        },
      ),
      routes: {
        'profile': (context) => ProFilePage(),
        'signup': (context) => SignUpPage(),
        'signin': (context) => SignInPage(),
        'camera': (context) => CameraPage(camera: firstCamera),
        'alarm': (context) => AlarmPage(),
        'home': (context) => HomePage(),
        'calender': (context) => CalenderPage(),
        'friendpage': (context) => FriendPage(),
        'ootd': (context) => ootdHomePage(),
        'rec': (context) => MusicRecPage(),
      },
    );
  }
}