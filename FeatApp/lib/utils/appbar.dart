import 'package:flutter/material.dart';

// 공통 AppBar 위젯
PreferredSizeWidget buildAppBar(BuildContext context, String pageTitle) {

  final size = MediaQuery.of(context).size;

  return AppBar(
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    leading: IconButton(padding: EdgeInsets.zero, constraints: BoxConstraints(), onPressed: (){
      Navigator.pop(context);
    }, icon: Icon(Icons.arrow_back, size: size.width * 0.075), color: Colors.black),
    title: Text(pageTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.065)),
    centerTitle: false,
  );
}