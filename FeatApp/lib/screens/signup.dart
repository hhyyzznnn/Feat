import 'package:feat/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.black54, selectionColor: Colors.black26
        ),
        inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54,),
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black,)
            ),
            contentPadding: EdgeInsets.only(left: 10)
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Sign',
      home: Sign(),
    );
  }
}

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {

  Future<void> saveUserInfo(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('token', token);
  }

  final formKey = GlobalKey<FormState>();

  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController pwCheckController = TextEditingController();


  Future<void> sign(BuildContext context) async {
    final String userName = userNameController.text;
    final String userEmail = userEmailController.text;
    final String id = idController.text;
    final String pw = pwController.text;
    final String pwCheck = pwCheckController.text;

    final Map<String, String> data = {
      "userName": userName,
      "userEmail": userEmail,
      "id": id,
      "pw": pw,
      "pwCheck": pwCheck
    };
  }

  String? errorMessage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isFieldTouched = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (BuildContext context) => Login(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('회원가입', style: TextStyle(),),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 60),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                //이름
                SizedBox(
                  child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    onChanged: (val) {
                      if (isFieldTouched) {
                        _formKey.currentState!.validate();
                      }
                    },
                    validator: (val) {
                      if (val!.isEmpty) {
                        return '이름은 필수 사항입니다.';
                      }

                      if (val.length < 2) {
                        return '이름은 두 글자 이상 입력해주세요.';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20,),

                //이메일
                SizedBox(
                  child: TextFormField(
                    key: ValueKey(2),
                    controller: userEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      //errorText: errorMessage,
                    ),
                    onChanged: (val) {
                      if (isFieldTouched) {
                        _formKey.currentState!.validate();
                      }
                    },
                    validator: (val) {
                      if(val!.isEmpty) {
                        return '이메일은 필수 사항입니다.';
                      }

                      if(!RegExp(
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                          .hasMatch(val)){
                        return '잘못된 이메일 형식입니다.';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20,),

                //아이디
                SizedBox(
                  child: TextFormField(
                    key: ValueKey(3),
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: 'ID',
                      errorText: errorMessage,
                    ),
                    onChanged: (val) {
                      if (isFieldTouched) {
                        _formKey.currentState!.validate();
                      }
                    },
                    validator: (val) {
                      if(val!.isEmpty){
                        return '아이디는 필수 사항입니다.';
                      }
                      if(val.length < 8){
                        return '아이디는 8자 이상 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),

                //비밀번호
                SizedBox(
                  child: TextFormField(
                    obscureText: true,
                    key: ValueKey(4),
                    controller: pwController,
                    decoration: InputDecoration(
                      labelText: 'PW',
                    ),
                    onSaved: (newValue) {},
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),

                //비밀번호 확인
                SizedBox(
                  child: TextFormField(
                      obscureText: true,
                      controller: pwCheckController,
                      validator: (value) {
                        if (pwController.text != pwCheckController.text) {
                          return '비밀번호와 일치하지 않습니다.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'PW 확인',
                      )
                  ),
                ),
                SizedBox(height: 50,),
                //회원가입 버튼
                ElevatedButton(
                  onPressed: (){
                    setState(() {
                      isFieldTouched = true; // 필드가 터치되었음을 표시
                    });
                    //if (_formKey.currentState!.validate()) {
                      //ScaffoldMessenger.of(context).showSnackBar(
                        //SnackBar(content: Text('회원가입이 성공적으로 완료되었습니다.')),
                      //);
                      // 추가 로직 (예: 서버에 데이터 전송)
                    //}
                    Navigator.push(context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Login(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text('가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}