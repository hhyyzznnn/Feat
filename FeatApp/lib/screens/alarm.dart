import 'package:flutter/material.dart';
import 'package:feat/utils/appbar.dart';

class Alarm2Page extends StatefulWidget {
  const Alarm2Page({super.key});

  @override
  State<Alarm2Page> createState() => _Alarm2PageState();
}

class _Alarm2PageState extends State<Alarm2Page> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, '알람'),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
            AlarmBox(),
          ],
        ),
      )
    );
  }
}

class AlarmBox extends StatelessWidget {
  const AlarmBox({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'calendar');
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.025),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
        width: size.width * 0.9,
        height: size.height * 0.115,
        decoration: BoxDecoration(
          color: Color(0xff3F3F3F),
          borderRadius: BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Color(0xff000000).withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4)
            ),
          ],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Icon(Icons.circle, color: Color(0xffebebeb), size: size.width * 0.2),
            ),
            SizedBox(
                width: size.width * 0.45,
                height: size.height * 0.15,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child:Container(
                          margin: EdgeInsets.fromLTRB(20, 22, 0, 0),
                          child: Text('Username', style: TextStyle(fontSize: size.width * 0.05, fontWeight: FontWeight.bold, color: Colors.white))),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text('내용', style: TextStyle(fontSize: size.width * 0.04, fontWeight: FontWeight.w400, color: Colors.white))),
                    )
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
