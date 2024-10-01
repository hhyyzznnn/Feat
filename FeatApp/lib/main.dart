import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart'; // 추가된 패키지
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'screens/alarm.dart';
import 'screens/camera.dart';
import 'screens/calender.dart';
import 'screens/friendpage.dart';
import 'screens/ootd.dart';
import 'screens/music_rec2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.isNotEmpty ? cameras.first : null; // 카메라가 없을 경우 처리
  runApp(MaterialApp(home: MusicRecPage())); //FeatApp(firstCamera: firstCamera)
}

class FeatApp extends StatelessWidget {
  final CameraDescription? firstCamera; // 카메라가 없을 경우 null 허용

  const FeatApp({super.key, required this.firstCamera});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    return userId != null;
  }

  Future<bool> isPhysicalDevice() async {
    var deviceInfo = DeviceInfoPlugin();
    var iosInfo = await deviceInfo.iosInfo;
    return iosInfo.isPhysicalDevice; // 실제 기기 여부 반환
  }

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
        'camera': (context) => FutureBuilder<bool>(
          future: isPhysicalDevice(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasData && snapshot.data == true && firstCamera != null) {
              // 실제 기기인 경우 카메라 기능 사용
              return CameraPage(camera: firstCamera!);
            } else {
              // 시뮬레이터나 카메라가 없는 경우 대체 화면 제공
              return Scaffold(
                appBar: AppBar(title: Text("카메라 사용 불가")),
                body: Center(
                  child: Text(
                    "카메라를 사용할 수 없습니다. 실제 기기에서 테스트하세요.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }
          },
        ),
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

/* import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'screens/alarm.dart';
import 'screens/camera.dart';
import 'screens/calender.dart';
import 'screens/friendpage.dart';
import 'screens/ootd.dart';
import 'screens/music_rec.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(FeatApp(firstCamera: firstCamera));
}

class FeatApp extends StatelessWidget {
  final CameraDescription firstCamera;

  const FeatApp({super.key, required this.firstCamera});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    return userId != null; // '=='를 '!='로 수정해야 함. 코딩 위해서 임의로 바꿔놓음
  }

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
        'rec': (context) => MusicRecPage()
      },
    );
  }
} */