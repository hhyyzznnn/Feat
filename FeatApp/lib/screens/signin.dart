import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feat/screens/home.dart';
import 'package:feat/screens/signup.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // 유저의 입력 아이디 패스워드 서버에 전송 후 확인하는 과정

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    //서버로 데이터 전송시 json 형식으로 전환하는 코드
    final String userId = userIdController.text;
    final String password = passwordController.text;

    final Map<String, String> data = {
      "userId": userId,
      "password": password,
    };

    // post 요청 보내기
    final http.Response response = await http.post(
      Uri.parse('http://172.24.4.212:8080/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      saveUserId(userId);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    } else {
      showSnackBar(
          context, const Text('아이디 또는 비밀번호가 잘못되었습니다. 아이디와 비밀번호를 정확히 입력해주세요.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feat.'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
                child: TextFormField(
                    controller: userIdController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.5)),
                      labelText: 'ID',
                      labelStyle: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    )),
              ),
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
                child: TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.5)),
                        labelText: 'PW',
                        labelStyle: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ))),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: Text('회원가입'),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                          child: Text('아이디 찾기')),
                      Text(
                        '/',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                          child: Text('비밀번호 찾기')),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: ElevatedButton(
                onPressed: () {
                  login(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0.0,
                ),
                child: Text('로그인'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(255, 112, 48, 48),
  );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('로그인 성공');
  }
}
