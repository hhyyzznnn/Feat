import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:feat/screens/camera_preview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:intl/intl.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isFlashOn = false; // 후레쉬 상태
  bool isFrontCamera = false; // 현재 카메라 상태
  double _currentZoomLevel = 1.0; // 현재 줌 레벨
  double _maxZoomLevel = 4.0; // 최대 줌 레벨, 카메라에 따라 조정 필요
  double _zoomFactor = 0.05; // 줌 변경 감도


  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize(); // 카메라 컨트롤러 초기화
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller.value.flashMode == FlashMode.off) {
      await _controller.setFlashMode(FlashMode.torch);
      setState(() {
        isFlashOn = true;
      });
    } else {
      await _controller.setFlashMode(FlashMode.off);
      setState(() {
        isFlashOn = false;
      });
    }
  }

  Future<void> _toggleCamera() async {
    final cameras = await availableCameras();
    CameraDescription newCamera;

    if (isFrontCamera) {
      newCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    } else {
      newCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    }

    await _initializeCamera(newCamera);
    setState(() {
      isFrontCamera = !isFrontCamera; // 카메라 상태 반전
    });
  }

  Future<String> getUploadUrl(String userId, String fileName) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.post(
        Uri.parse('http://172.24.4.212:8080/upload/post'),
        headers: {'Content-Type': 'application/json'},
        body: '{"userId": "$userId", "fileName": "$fileName", "date": "$today"}'
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to upload file: ${response.reasonPhrase}'); // 예외 던지기
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.065),
        child: AppBar(
            leading: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, size: size.width * 0.075),
                color: Colors.white),
            backgroundColor: Colors.black),
      ),
      body: GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            // 스케일이 커질 때와 작아질 때 각각의 변화율을 설정
            if (details.scale > 1) {
              // 줌 인
              _currentZoomLevel = (_currentZoomLevel + _zoomFactor).clamp(1.0, _maxZoomLevel);
            } else if (details.scale < 1) {
              // 줌 아웃
              _currentZoomLevel = (_currentZoomLevel - _zoomFactor).clamp(1.0, _maxZoomLevel);
            }
            _controller.setZoomLevel(_currentZoomLevel);
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  width: size.width * 0.92,
                  height: size.width * 0.92 * (16 / 9),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller);
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  height: size.height * 0.1,
                  color: Colors.black,
                ),
              ],
            ),
            Positioned(
              bottom: size.height * 0.015                      ,
              child: GestureDetector(
                onTap: () async {
                  try {
                    await _initializeControllerFuture;

                    final image = await _controller.takePicture();
                    File imageFile = File(image.path); // File 객체 생성

                    if (!context.mounted) return;

                    // 업로드 URL을 가져온 후 이미지를 업로드
                    String uploadUrl = await getUploadUrl('user1', 'image.jpg');
                    await uploadImageToUrl(uploadUrl, imageFile);

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PreviewPage(imagePath: image.path),
                      ),
                    );
                  } catch (e) {
                    print(e);
                  }
                },
                child: Container(
                  width: size.width * 0.275,
                  height: size.width * 0.275,
                  decoration: BoxDecoration(
                    color: Color(0xff3f3f3f),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                        width: size.width * 0.015, color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xff000000).withOpacity(0.25),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 4)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.15,
              right: size.width * 0.1,
              child: IconButton(
                icon: SvgPicture.asset(
                  isFlashOn ? 'assets/icons/flash_on.svg' : 'assets/icons/flash_off.svg',
                ),
                onPressed: _toggleFlash,
              ),
            ),
            // Camera switch button
            Positioned(
              bottom: size.height * 0.15,
              left: size.width * 0.1,
              child: IconButton(
                icon: SvgPicture.asset('assets/icons/refresh.svg'),
                onPressed: _toggleCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
