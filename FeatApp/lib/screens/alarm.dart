import 'package:flutter/material.dart';
import 'package:feat/utils/appbar.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {

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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'calendar');
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(25, 10, 20, 10),
        padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
        width: 200,
        height: 90,
        decoration: BoxDecoration(
          color: Color(0xff3F3F3F),
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Color(0xff000000).withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Icon(Icons.circle, color: Color(0xffebebeb), size: 60 ),
            ),
            SizedBox(
                width: 100,
                height: 90,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child:Container(
                          margin: EdgeInsets.fromLTRB(20, 22, 0, 0),
                          child: Text('username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white))),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text('내용', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white))),
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
