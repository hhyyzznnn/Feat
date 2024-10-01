import 'dart:convert';
import 'package:flutter/material.dart';
import 'ootd.dart';
import 'package:feat/utils/appbar.dart';
import 'package:http/http.dart' as http;

class CalenderPage extends StatelessWidget {
  CalenderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: buildAppBar(context, '달력'),
          body: Container(color: Colors.white, child: CalenderHomePage())),
    );
  }
}

class CalenderDate extends StatefulWidget {
  CalenderDate({super.key, this.day, this.year, this.month});
  final now = DateTime.now;
  var day;
  var year;
  var month;

  @override
  State<CalenderDate> createState() => _CalenderDateState();
}

class _CalenderDateState extends State<CalenderDate> {
  List<String?> specialDates = ["2024-09-27", "2024-09-23"];

  final String userId = "user1";

  @override
  void initState() {
    super.initState();
    loadDates();
  }


  Future<void> loadDates() async {
    final url = Uri.parse('http://192.168.116.212:8080/load/dates');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          specialDates = List<String?>.from(
              jsonDecode(response.body));
          print(specialDates);
        });
      } else {
        throw Exception('Failed to load dates');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String dayModify(int? day) {
    return day != null && day < 10 ? '0$day' : day.toString();
  }

  String monthModify(int? month) {
    return month != null && month < 10 ? '0$month' : month.toString();
  }

  String yearModify(int? year) {
    return year?.toString() ?? '';
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = '${yearModify(widget.year)}-${monthModify(widget.month)}-${dayModify(widget.day)}';

    if (widget.day == 0) {
      return Container(
          width: 50,
          height: 50,
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white));
    } else if (widget.day != 0 && specialDates.contains(formattedDate)) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ootdHomePage(
                      year: yearModify(widget.year),
                      month: monthModify(widget.month),
                      day: dayModify(widget.day))));
          print(yearModify(widget.year) +
              monthModify(widget.month) +
              dayModify(widget.day));
        },
        child: Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Color(0xFFFC4318).withOpacity(0.5)),
            child: Align(
                alignment: Alignment.center,
                child: Text(widget.day.toString(),
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))),
      );
    }
    else {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ootdHomePage(
                      year: yearModify(widget.year),
                      month: monthModify(widget.month),
                      day: dayModify(widget.day))));
          print(yearModify(widget.year) +
              monthModify(widget.month) +
              dayModify(widget.day));
        },
        child: Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: Align(
                alignment: Alignment.center,
                child: Text(widget.day.toString(),
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))),
      );
    }
  }
}

class CalenderHomePage extends StatefulWidget {
  CalenderHomePage({super.key});

  final now = DateTime.now();
  var startYear = 2024;
  var startMonth = 6;

  @override
  State<CalenderHomePage> createState() => _CalenderHomePageState();
}

class _CalenderHomePageState extends State<CalenderHomePage> {
  var scroll = ScrollController();

  searchTargetIndex(startDate, nowDate) {
    //달력 하나 위젯 크기 알아내서 인덱스 차에 곱하기 466.5
    // state 전송 필요 x
    // init 스테이트에서 타겟 인덱스 잡아주고 진행하기

    var gap;

    if (startDate[0] == nowDate[0]) {
      gap = nowDate[1] - startDate[1];
    } else {
      gap = (nowDate[0] - startDate[0]) * 12 + (nowDate[1] - startDate[1]);
    }

    return gap * 466.7;
  }

  void scrollToPosition(gap) {
    scroll.animateTo(gap,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double targetPosition = searchTargetIndex(
          [widget.startYear, widget.startMonth],
          [widget.now.year, widget.now.month]);
      scrollToPosition(targetPosition);
    });
  }

  yearAndMonth(int plusmonth, int year, int month) {
    int newMonth = month + plusmonth;
    int newYear = year;

    if (newMonth > 12) {
      newYear += (newMonth - 1) ~/ 12;
      newMonth = (newMonth - 1) % 12 + 1;
    }

    return [newYear, newMonth];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 12,
        controller: scroll,
        itemBuilder: (context, index) {
          return Column(children: [
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 30, 0, 10),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Text(
                      '${yearAndMonth(index, widget.startYear, widget.startMonth)[0]}__${yearAndMonth(index, widget.startYear, widget.startMonth)[1]}',
                      style:
                      TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
                )),
            SizedBox(width: 450, height: 70, child: CalendarBar()),
            SizedBox(
                width: 450,
                height: 340,
                child: CalendarDateGridView(index: index))
          ]);
        });
  }
}

// 캘린더 구현
// 1 캘린더 데이트 위젯 배치로 1달 캘린더 만들기
// 최대 6주 이므로 6 * 7로 구성

class CalendarDateGridView extends StatefulWidget {
  CalendarDateGridView({super.key, this.index});

  var index;
  var startYear = 2024;
  var startMonth = 6;

  @override
  State<CalendarDateGridView> createState() => _CalendarDateGridViewState();
}

class _CalendarDateGridViewState extends State<CalendarDateGridView> {
  final now = DateTime.now();
  late int year;
  late int month;

  yearAndMonth(int plusmonth, int year, int month) {
    int newMonth = month + plusmonth;
    int newYear = year;

    if (newMonth > 12) {
      newYear += (newMonth - 1) ~/ 12;
      newMonth = (newMonth - 1) % 12 + 1;
    }

    return [newYear, newMonth];
  }

  int monthDay(int month, int year) {
    if ([1, 3, 5, 7, 8, 10, 12].contains(month)) {
      return 31;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
      } else {
        return 28;
      }
    }
  }

  int firstDay(int year, int month) {
    // 원하는 년도의 1월 1일 요일 알아 내기
    int sum = 0;

    for (int i = 1583; i < year; i++) {
      if ((i % 4 == 0 && i % 100 != 0) || i % 400 == 0) {
        sum += 2;
      } else {
        sum += 1;
      }
    }

    int first = (sum + 6) % 7; // 일월화수목금토는 각 0123456에 대입됨

    for (int j = 1; j < month; j++) {
      first += monthDay(j, year) % 7;
    }

    return first % 7;
  }

  @override
  void initState() {
    super.initState();
    year = yearAndMonth(widget.index, widget.startYear, widget.startMonth)[0];
    month = yearAndMonth(widget.index, widget.startYear, widget.startMonth)[1];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // 열의 수
          crossAxisSpacing: 2.0, // 열 간의 간격
          mainAxisSpacing: 2.0, // 행 간의 간격
        ),
        itemCount: 35, // 총 아이템 수 (7 * 6)
        itemBuilder: (context, index) {
          if (index >= firstDay(year, month)) {
            var day = index - firstDay(year, month) + 1;

            if (day > monthDay(month, year)) {
              return CalenderDate(day: 0);
            } else {
              return CalenderDate(day: day, year: year, month: month);
            }
          } else {
            return CalenderDate(day: 0);
          }
        },
      ),
    );
  }
}

class CalendarBar extends StatelessWidget {
  CalendarBar({super.key});

  var date = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: GridView.builder(
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(date[index], style: TextStyle(fontSize: 20))));
        },
      ),
    );
  }
}