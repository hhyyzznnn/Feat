import 'package:flutter/material.dart';

class ootdHomePage extends StatelessWidget {
  ootdHomePage({super.key, this.year, this.month, this.day});

  var year;
  var month;
  var day;

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Text('Feat.',
              style: TextStyle(
                  fontSize: size.height * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
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
                color: Colors.black87,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.025),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'profile');
                },
                borderRadius: BorderRadius.circular(size.height * 0.02),
                child: ClipOval(
                  child: Icon(Icons.person, size: size.height * 0.035),
                ),
              ),
            )
          ],
        ),
        body: ootdBody(year: year, month: month, day: day),
      ),
    );
  }
}


class ootdBody extends StatelessWidget {
  ootdBody({super.key, this.year, this.month, this.day});

  var year;
  var month;
  var day;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(27, 10, 0, 10),
                  child: Text('$year. $month. $day', style: TextStyle(fontSize: 22))),
              Spacer()
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 15, 20, 15),
            height: 480,
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xffebebeb),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff000000).withOpacity(0.25),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xffebebeb),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff000000).withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(0, 4), // changes position of shadow
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
                width: 200,
                child: Column(
                  children: [
                    Align(alignment: Alignment.centerLeft ,child: Text('Music Name', style: TextStyle(fontSize: 22))),
                    Align(alignment: Alignment.centerLeft ,child: Text('0000', style: TextStyle(fontSize: 15))),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}