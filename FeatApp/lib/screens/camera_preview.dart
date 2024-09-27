import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'music_rec.dart';

class PreviewPage extends StatelessWidget {
  final String imagePath;

  PreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerWidth = size.width * 0.92;
    final containerHeight = containerWidth * 16 / 9;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 이미지 프리뷰
          Positioned(
            bottom: size.height * 0.13,
            left: size.width * 0.04,
            right: size.width * 0.04,
            child: Center(
              child: SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          // 뒤로 가기 버튼
          Positioned(
            top: size.height * 0.02,
            left: size.width * 0.02,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: size.width * 0.075, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // + 버튼
          Positioned(
            bottom: size.height * 0.05,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center, // Stack 내에서 모든 위젯을 중앙 정렬
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MusicRecPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), // 원형 버튼으로 만들기
                    backgroundColor: Color(0xff3F3F3F), // 배경색
                    padding: EdgeInsets.zero, // 내부 패딩 없애기
                    side: BorderSide(color: Colors.black, width: 10), // 검정 테두리
                    minimumSize: Size(size.width * 0.3, size.width * 0.3), // 크기 설정
                  ),
                  child: Container(
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // 원형으로 만들기
                    ),
                  ),
                ),
                // 중앙에 + 모양의 SVG 추가
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MusicRecPage()),
                    );
                  },
                  child: SvgPicture.asset('assets/icons/plus.svg',),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}