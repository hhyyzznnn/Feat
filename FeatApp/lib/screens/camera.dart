import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
<<<<<<< Updated upstream
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'camera_preview.dart';
=======
import 'package:intl/intl.dart';
import 'dart:convert';

>>>>>>> Stashed changes

class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  const CameraPage({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller; // null safety 적용
  Future<void>? _initializeControllerFuture; // 카메라 초기화 완료를 위한 Future
  bool _isFlashOn = false; // 후레쉬 상태 플래그
  late List<CameraDescription> _cameras; // 카메라 리스트
  int _selectedCameraIndex = 0; // 현재 선택된 카메라 인덱스 (0: 후면, 1: 전면)
  File? _galleryImage;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraInitialized = false; // 카메라 초기화 상태

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // 권한 요청 메서드
  Future<void> _requestPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    if (await Permission.camera.isGranted) {
      _initializeCameras();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  // 권한 거부 시 경고창
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('카메라 권한이 필요합니다'),
          content: Text('카메라 기능을 사용하려면 권한이 필요합니다. 설정에서 권한을 허용해 주세요.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 카메라 초기화
  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isNotEmpty) {
        _initializeController();
      } else {
        print("사용 가능한 카메라가 없습니다.");
      }
    } catch (e) {
      print("카메라 초기화 중 에러 발생: $e");
    }
  }

  void _initializeController() async {
    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller?.initialize();
    await _initializeControllerFuture;

    setState(() {
      _isCameraInitialized = true; // 카메라 초기화 완료 상태
    });
  }

  @override
  void dispose() {
    _controller?.dispose(); // 컨트롤러 해제
    super.dispose();
  }

<<<<<<< Updated upstream
  void _toggleFlash() async {
    if (_controller?.value.isInitialized ?? false) {
      _isFlashOn = !_isFlashOn;
      await _controller?.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
=======
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

    // 파일 이름과 확장자를 분리
    int extensionIndex = fileName.lastIndexOf('.');
    String baseName = fileName.substring(0, extensionIndex);
    String extension = fileName.substring(extensionIndex);

    // 파일 이름에 유저 아이디와 날짜 추가
    String modifiedFileName = '$baseName+_$today+_$userId$extension';

    final response = await http.post(
      Uri.parse('http://172.24.4.212:8080/upload/post'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": userId,
        "fileName": modifiedFileName,
        "date": today
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to upload file: ${response.reasonPhrase}');
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
>>>>>>> Stashed changes
      );
      setState(() {});
    }
  }

  void _switchCamera() {
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });
    _initializeController(); // 새로운 카메라로 초기화
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture(); // 사진 촬영

      // 앱의 문서 디렉토리에 사진 저장
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${DateTime.now()}.png';

      final file = File(path);
      await file.writeAsBytes(await image.readAsBytes());

      setState(() {
        _imagePath = path; // 이미지 경로 저장
      });

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewPage(imagePath: image.path), // 사진 미리보기 페이지로 이동
        ),
      );
    } catch (e) {
      print(e); // 에러 출력
    }
  }

  // 갤러리에서 이미지 가져오기
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _galleryImage = File(pickedFile.path); // 선택한 이미지 저장
        _imagePath = pickedFile.path; // 이미지 경로 저장
      });

      // 프리뷰 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(imagePath: _imagePath!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerWidth = size.width * 0.92;
    final containerHeight = containerWidth * 16 / 9;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 뒤로가기 버튼
          Positioned(
            top: size.height * 0.05,
            left: size.width * 0.04,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: size.width * 0.075, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // 이전 화면으로 이동
              },
            ),
          ),
          // 카메라 미리보기 부분
          if (_isCameraInitialized && _controller != null)
            Positioned(
              bottom: size.height * 0.13,
              left: size.width * 0.04,
              right: size.width * 0.04,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            Center(child: CircularProgressIndicator()), // 카메라가 초기화되지 않았을 때 로딩 표시
          // 플래쉬 버튼
          Positioned(
            left: size.width * 0.06,
            bottom: size.height * 0.14,
            child: IconButton(
              icon: SvgPicture.asset(
                _isFlashOn ? 'assets/icons/flash_on.svg' : 'assets/icons/flash_off.svg',
              ),
              onPressed: _toggleFlash,
            ),
          ),
          // 카메라 전환 버튼
          Positioned(
            right: size.width * 0.06,
            bottom: size.height * 0.14,
            child: IconButton(
              icon: SvgPicture.asset('assets/icons/refresh.svg'),
              onPressed: _switchCamera,
            ),
          ),
          // 사진 촬영 버튼
          Positioned(
            bottom: size.height * 0.05,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _takePicture,
                customBorder: CircleBorder(),
                child: Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  decoration: BoxDecoration(
                    color: Color(0xff3F3F3F),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 10),
                  ),
                ),
              ),
            ),
          ),
          // 갤러리에서 사진 가져오기 버튼
          Positioned(
            left: size.width * 0.07,
            bottom: size.height * 0.05,
            child: GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xffCDCDCD),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: size.width * 0.13,
                height: size.width * 0.13,
                child: _galleryImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _galleryImage!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(Icons.photo, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}