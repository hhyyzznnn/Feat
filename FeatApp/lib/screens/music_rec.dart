import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feat/utils/appbar.dart';

class MusicRecPage extends StatefulWidget {
  @override
  _MusicRecPageState createState() => _MusicRecPageState();
}

class _MusicRecPageState extends State<MusicRecPage> {
  final List<String> musicList = [
    'Song 1',
    'Song 2',
    'Song 3',
    'Song 4',
    'Song 5',
  ];

  late AudioPlayer audioPlayer;
  int currentSongIndex = 0; // 현재 재생 중인 노래 인덱스
  bool isPlaying = false;
  double volume = 0.5;
  Duration currentDuration = Duration.zero; // 현재 재생된 시간
  Duration totalDuration = Duration.zero; // 전체 음악 길이

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setVolume(volume); // 초기 볼륨 설정
    _playMusic(); // 시작 시 첫 곡 재생

// 음악의 진행 시간 및 전체 길이 업데이트
    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentDuration = position;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _playMusic() async {
    String url = 'https://example.com/${musicList[currentSongIndex]}.mp3'; // 각 곡의 URL로 수정
    await audioPlayer.play(UrlSource(url));
    await audioPlayer.setVolume(volume);
    setState(() {
      isPlaying = true;
      currentDuration = Duration.zero; // 음악 재생 시작 시 초기화

// 전체 음악 길이를 가져오기
      audioPlayer.getDuration().then((duration) {
        setState(() {
          totalDuration = duration ?? Duration.zero;
        });
      });
    });
  }

  void _pauseMusic() {
    audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void _resumeMusic() {
    audioPlayer.resume();
    setState(() {
      isPlaying = true;
    });
  }

  void _rewindMusic() {
    setState(() {
      if (currentSongIndex > 0) {
        currentSongIndex--;
        _playMusic(); // 이전 곡 재생
      }
    });
  }

  void _fastForwardMusic() {
    setState(() {
      if (currentSongIndex < musicList.length - 1) {
        currentSongIndex++;
        _playMusic(); // 다음 곡 재생
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: buildAppBar(context, ' '),
      body: Stack(
        children: [
// 음악 재생 버튼
          Align(
            alignment: Alignment(0, 0.65),
            child: SizedBox(
              width: size.width * 0.65,
              height: size.height * 0.13,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
// 뒤로 감기 버튼
                  IconButton(
                    icon: SvgPicture.asset('assets/icons/rewind.svg'),
                    onPressed: _rewindMusic,
                  ),
// 정지 버튼
                  IconButton(
                    icon: isPlaying
                        ? SvgPicture.asset('assets/icons/pause.svg')
                        : SvgPicture.asset('assets/icons/play.svg'),
                    // Play/Pause 아이콘
                    onPressed: isPlaying ? _pauseMusic : _resumeMusic,
                  ),
// 앞으로 감기 버튼
                  IconButton(
                    icon: SvgPicture.asset('assets/icons/fast_forward.svg'),
                    onPressed: _fastForwardMusic,
                  ),
                ],
              ),
            ),
          ),
// 음악 볼륨 조정
          Align(
            alignment: Alignment(0, 0.8),
            child: SizedBox(
              width: size.width * 0.9,
              height: size.height * 0.05,
              child: Row(
                children: [
// volume down 버튼
                  IconButton(
                    icon: SvgPicture.asset('assets/icons/volume_down.svg'),
                    onPressed: () {
                      setState(() {
                        if (volume > 0) {
                          volume = (volume - 0.1).clamp(0.0, 1.0); // 볼륨 감소
                          audioPlayer.setVolume(volume); // 볼륨 설정
                        }
                      });
                    },
                  ),
// volume 조정 영역
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
// 드래그의 위치를 비율로 계산하여 볼륨 조정
                        double newVolume = (details.localPosition.dx /
                            (size.width * 0.66)).clamp(0.0, 1.0);
                        volume = newVolume;
                        audioPlayer.setVolume(volume);
                      });
                    },
                    child: Container(
                      width: size.width * 0.66,
                      height: size.height * 0.011,
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Stack(
                        children: [
// 현재 볼륨에 따라 색상 변화
                          Positioned(
                            left: 0,
                            right: (1 - volume) * size.width * 0.66,
                            child: Container(
                              height: size.height * 0.011,
                              decoration: BoxDecoration(
                                color: Color(0xff3F3F3F), // 볼륨이 증가할 때 색상
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
// volume up 버튼
                  IconButton(
                    icon: SvgPicture.asset('assets/icons/volume_up.svg'),
                    onPressed: () {
                      setState(() {
                        if (volume < 1.0) {
                          volume = (volume + 0.1).clamp(0.0, 1.0); // 볼륨 증가
                          audioPlayer.setVolume(volume); // 볼륨 설정
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
// Main music
          Align(
            alignment: Alignment(0, -0.9),
            child: Container(
              width: size.width * 0.9,
              height: size.height * 0.1, // 메인 음악 컨테이너 크기 조정
              decoration: ShapeDecoration(
                color: Color(0xFFF0EADF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
// 앨범 커버 이미지
                  Container(
                    width: size.width * 0.16,
                    height: size.width * 0.16,
                    margin: EdgeInsets.only(left: 16, right: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://example.com/album_cover_${musicList[currentSongIndex]}.jpg',
                        ), // 현재 재생 중인 곡의 앨범 커버 이미지 URL
                        fit: BoxFit.cover, // 이미지를 맞춤 설정
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${musicList[currentSongIndex]}\n',
                            // 메인 음악 제목
                            style: TextStyle(
                              color: Colors.black,
                              // 메인 음악 텍스트 색상 조정
                              fontSize: 22,
                              // 메인 음악 타이틀의 글자 크기
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: 'Artist Name', // 추가 정보 (예: 아티스트 이름)
                            style: TextStyle(
                              color: Colors.black,
                              // 서브 텍스트 색상
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.61),
            child: Container(
              width: size.width * 0.9,
              height: size.height * 0.001,
              color: Color(0xFFc7c7c7),
            ),
          ),
// music list
          Align(
            alignment: Alignment(0, -0.3),
            child: SizedBox(
              width: size.width * 0.88,
              height: size.height * 0.4,
              child: ListView.builder(
                itemCount: musicList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(13),
                    decoration: ShapeDecoration(
                      color: Color(0xFF3F3F3F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
// 앨범 커버 이미지
                        Container(
                          width: size.width * 0.12,
                          height: size.width * 0.12,
                          margin: EdgeInsets.only(right: 32), // 텍스트와 간격 조정
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${musicList[index]}\n', // 음악 제목
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: '000',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.27),
            child: Container(
              width: size.width * 0.9,
              height: size.height * 0.001,
              color: Color(0xFFc7c7c7),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.45),
            child: SizedBox(
              width: size.width * 0.9,
              height: size.height * 0.04,
              child: Stack(
                children: [
// music box
                  Align(
                    alignment: Alignment(0, -1),
                    child: Container(
                      width: size.width * 0.9,
                      height: size.height * 0.011,
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
// 배경 Container 안에서만 슬라이드 계산
                            double newPosition = (details.localPosition.dx /
                                (size.width * 0.9))
                                .clamp(0.0, 1.0); // 범위를 0.0 ~ 1.0 사이로 제한
                            currentDuration = Duration(
                                seconds: (newPosition * totalDuration.inSeconds)
                                    .toInt());
                            audioPlayer.seek(currentDuration); // 새로운 재생 시간으로 이동
                          });
                        },
                        child: Stack(
                          children: [
// 현재 재생된 부분을 색상으로 표시
                            Positioned(
                              left: 0,
                              right: (1 - currentDuration.inSeconds /
                                  totalDuration.inSeconds) *
                                  size.width * 0.9,
                              child: Container(
                                height: size.height * 0.011, // 재생된 부분의 높이
                                decoration: BoxDecoration(
                                  color: Color(0xff3F3F3F), // 현재 재생된 부분의 색상
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
// 현재 재생 시간
                  Align(
                    alignment: Alignment(-1, 1),
                    child: Text(
                      formatDuration(currentDuration),
                      style: TextStyle(fontSize: 16, color: Color(0xff8B8B8B)),
                    ),
                  ),
                  Align(
                    alignment: Alignment(1, 1),
                    child: Text(
                      formatDuration(totalDuration),
                      style: TextStyle(fontSize: 16, color: Color(0xff8B8B8B)),
                    ),
                  ),
                ],
              ),


/*child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 현재 재생 시간
                  Text(
                    formatDuration(currentDuration),
                    style: TextStyle(fontSize: 16, color: Color(0xff8B8B8B)),
                  ),
                  // 전체 재생 시간
                  Text(
                    formatDuration(totalDuration),
                    style: TextStyle(fontSize: 16, color: Color(0xff8B8B8B)),
                  ),
                ],
              ),*/
            ),
          ),
        ],
      ),
    );
  }
}