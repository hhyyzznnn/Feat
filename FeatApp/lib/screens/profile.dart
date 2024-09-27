import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feat/screens/signin.dart';
import 'package:http/http.dart' as http;
import 'package:feat/utils/appbar.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ProFilePage extends StatefulWidget {
  const ProFilePage({super.key});

  @override
  State<ProFilePage> createState() => _ProFilePageState();
}

class _ProFilePageState extends State<ProFilePage> {
  File? _image;
  final ImagePicker picker = ImagePicker();

  Map userSetting = {}; // 유저 세팅을 저장할 맵
  Map userInfo = {}; // 유저 정보를 저장할 맵
  Map ProfileImage = {}; // 프로필 사진 주소를 저장할 맵


  final String userId = "user1"; // 임의로 작성한 유저 아이디

  Future<void> sendUserId(String userId, String endpoint) async {
    final url =
        Uri.parse('http://172.24.4.212:8080/edit/$endpoint'); // 엔드포인트를 변수로 사용

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        print('User ID sent successfully');
      } else {
        print('Failed to send User ID: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadSettings() async {
    final url =
        Uri.parse('http://172.24.4.212:8080/load/alarmSetting'); // 설정 서버 주소 추가
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userSetting = Map.from(jsonDecode(response.body));

          reqNotifications = userSetting['friendRequest'] == 'on';
          friNotifications = userSetting['freindAlarm'] == 'on';
          allNotifications = userSetting['entireAlarm'] == 'on';
          print(userSetting);
        });
      } else {
        throw Exception('Failed to load setttings');
      }
    } catch (e) {
      print('Error: $e');
    }
  } // 유저 설정 불러오는 함수(서버)

  Future<void> loadInfo() async {
    final url =
        Uri.parse('http://172.24.4.212:8080/load/userInfo'); // 유저 정보 서버 주소 추가
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userInfo = Map.from(jsonDecode(response.body)); // JSON 데이터를 리스트로 변환
          print(userInfo);
        });
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      print('Error: $e');
    }
  } // 유저 정보 불러오는 함수 (서버)

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

  Future<void> deleteUserId(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  } // 로그아웃 함수

  Future<void> deleteAccount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse('http://'); // 계정 삭제 기능이 구현된 서버 주소
      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": userId}),
        );

        if (response.statusCode == 200) {
          await prefs.remove('userId');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
          );
        } else {
          throw Exception('Failed to delete account');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  } // 계정 삭제 함수

  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadInfo();
    loadSettings();
    loadProfile();
  }

    Future<void> requestPermissions() async {
      final camStatus = await Permission.camera.request();
      final phoStatus = await Permission.photos.request();
    } // 카메라, 갤러리 권한 (미사용)

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      String fileName = pickedFile.path.split('/').last;
      print('File name: $fileName');

      String? uploadUrl = await getUploadUrl(userId, fileName);

      if (uploadUrl != null) {
        await uploadImageToUrl(uploadUrl, _image!);
        print('File name: $fileName');
        loadProfile();

      } else {
        print('Failed to retrieve upload URL.');
      }
    }
  }

  void showPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: Wrap(
            children: [
              ListTile(
                  title: Text('카메라로 촬영'),
                  onTap: () {
                    pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text('갤러리에서 선택'),
                  onTap: () {
                    pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text('취소'),
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ],
          ));
        });
  } // 사진 촬영 or 갤러리 선택


  bool reqNotifications = false;
  bool friNotifications = false;
  bool allNotifications = false; // 서버 연결 후 코드 삭제할 예정

  void toggleReqNotifications(bool? value) {
    setState(() {
      reqNotifications = value ?? false;
      sendUserId(userId, 'friend/request');
    });
  }

  void toggleFriNotifications(bool? value) {
    setState(() {
      friNotifications = value ?? false;
      sendUserId(userId, 'friend/alarm');
    });
  }

  void toggleAllNotifications(bool? value) {
    setState(() {
      allNotifications = value ?? false;
      sendUserId(userId, 'entire/alarm');
    });
  }

  Future<String> getUploadUrl(String userId, String fileName) async {
    final response = await http.post(
      Uri.parse('http://172.24.4.212:8080/upload/profile'),
      headers: {'Content-Type': 'application/json'},
      body: '{"userId": "$userId", "fileName": "$fileName"}'
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to upload file: ${response.reasonPhrase}'); // 예외 던지기
    }
  } // 프로필 사진 업로드할 서버 주소 받아오기

  Future<void> uploadImageToUrl(String uploadUrl, File image) async {
    try {
      // 파일의 Content-Type을 파일 확장자로 추론
      final mimeType = image.path.split('.').last == 'jpg'
          ? 'image/jpeg'
          : 'image/${image.path.split('.').last}';

      // presigned URL을 통해 S3에 PUT 요청
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': mimeType, // Content-Type 설정
        },
        body: image.readAsBytesSync(), // 파일 데이터를 바이트 배열로 읽어오기
      );

      if (response.statusCode == 200) {
        print("Image uploaded successfully");
      } else {
        print("Image upload failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred during image upload: $e");
    }
  }

  void logoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                deleteUserId(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } // 로그아웃 확인

  void deleteAccountConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 삭제'),
          content: const Text('정말 계정을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                deleteAccount(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } // 계정 삭제 확인

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: buildAppBar(context, '프로필'),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.025,
              size.height * 0.035,
              size.width * 0.025,
              size.width * 0.015,
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color(0xff3f3f3f)),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(size.width * 0.05),
                            child: CircleAvatar(
                              radius: size.width * 0.2,
                              backgroundImage: ProfileImage['profile'] != null && ProfileImage['profile'].isNotEmpty
                                  ? NetworkImage(ProfileImage['profile']) as ImageProvider
                                  : (_image != null
                                  ? FileImage(_image!)
                                  : const AssetImage('hanni.jpg')),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.all(size.width * 0.025),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.all(size.width * 0.025),
                                      backgroundColor: Colors.grey,
                                      shape: CircleBorder(),
                                      side: BorderSide(
                                          color: Colors.white, width: 3)),
                                  onPressed: () => showPicker(context),
                                  child: Icon(Icons.camera_alt,
                                      color: Colors.white,
                                      size: size.width * 0.075)))
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Column(
                        children: [
                          Text('User Name',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.06,
                                  fontWeight: FontWeight.bold)),
                          Text('ID',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.05))
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.025),
                  child: Text('알림',
                      style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color(0xff3f3f3f)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.group, color: Colors.white),
                        title: Text('친구 요청',
                            style: TextStyle(color: Colors.white)),
                        trailing: CupertinoSwitch(
                          value: reqNotifications,
                          activeColor: Colors.black,
                          onChanged: toggleReqNotifications,
                        ),
                      ),
                      Divider(
                          height: 1,
                          color: Colors.grey,
                          indent: size.width * 0.025,
                          endIndent: size.width * 0.025),
                      ListTile(
                        leading: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        title: Text('친구 알림',
                            style: TextStyle(color: Colors.white)),
                        trailing: CupertinoSwitch(
                          value: friNotifications,
                          activeColor: Colors.black,
                          onChanged: toggleFriNotifications,
                        ),
                      ),
                      Divider(
                          height: 1,
                          color: Colors.grey,
                          indent: size.width * 0.025,
                          endIndent: size.width * 0.025),
                      ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        title: Text(
                          '전체 알림',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: CupertinoSwitch(
                          value: allNotifications,
                          activeColor: Colors.black,
                          onChanged: toggleAllNotifications,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.025),
                  child: Text('개인정보',
                      style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color(0xff3f3f3f)),
                  child: Column(
                    children: [
                      ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text('이메일',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.045)),
                          subtitle: Text(userInfo['userEmail'] ?? '이메일 없음',
                              style: TextStyle(color: Colors.grey))),
                      Divider(
                          height: 1,
                          color: Colors.grey,
                          indent: size.width * 0.025,
                          endIndent: size.width * 0.025),
                      ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text('전화번호',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.045)),
                          subtitle: Text(userInfo['userPhone'] ?? '전화번호 없음',
                              style: TextStyle(color: Colors.grey))),
                      Divider(
                          height: 1,
                          color: Colors.grey,
                          indent: size.width * 0.025,
                          endIndent: size.width * 0.025),
                      ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text('생년월일',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.045)),
                          subtitle: Text(userInfo['birthday'] ?? '생년월일 없음',
                              style: TextStyle(color: Colors.grey))),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          deleteAccountConfirm(context);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Color(0xff3f3f3f),
                            minimumSize:
                                Size(size.width * 0.45, size.height * 0.075),
                            alignment: Alignment.center),
                        child: Text(
                          '계정 삭제',
                          style: TextStyle(color: Colors.white),
                        )),
                    ElevatedButton(
                        onPressed: () {
                          logoutConfirm(context);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Color(0xff3f3f3f),
                            minimumSize:
                                Size(size.width * 0.45, size.height * 0.075),
                            alignment: Alignment.center),
                        child: Text(
                          '로그아웃',
                          style: TextStyle(color: Colors.red),
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}