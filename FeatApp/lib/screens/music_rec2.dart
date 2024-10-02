import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feat/utils/appbar.dart';

class MusicRecPage extends StatefulWidget {
  const MusicRecPage({super.key});

  @override
  State<MusicRecPage> createState() => _MusicRecPageState();
}

class _MusicRecPageState extends State<MusicRecPage> {
  final List<String> musicList = [
    'Song_1',
    'Song_2',
    'Song_3',
    'Song_4',
    'Song_5'
  ]; // 서버 연결 후 삭제 예정
  final List<String> url = [
    'https://www.youtube.com/watch?v=ojQoCfTRTkw',
    'https://www.youtube.com/watch?v=08h8u8Z9iJQ',
    'https://www.youtube.com/watch?v=3ERtNZqh1XA',
  ]; // YouTube 영상 URL

  late AudioPlayer audioPlayer;
  int currentSongIndex = 0;
  bool isPlaying = false;
  double volume = 0.5;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setVolume(volume);
    _playMusic();

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
    //String url = 'https://example.com/${musicList[currentSongIndex]}.mp3'; // 각 곡의 URL로 수정
    await audioPlayer.play(UrlSource(url[0]));
    await audioPlayer.setVolume(volume);
    setState(() {
      isPlaying = true;
      currentDuration = Duration.zero;
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

  void _previousMusic() {
    setState(() {
      if (currentSongIndex > 0) {
        currentSongIndex--;
        _playMusic(); // 이전 곡 재생
      }
    });
  }

  void _nextMusic() {
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context, ''),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            width: size.width * 0.9,
            height: size.height * 0.1,
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
                Container(
                  width: size.width * 0.16,
                  height: size.width * 0.16,
                  margin: EdgeInsets.only(left: 15, right: 25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey,
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://example.com/album_cover_${musicList[currentSongIndex]}.jpg',
                      ),
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
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.5)),
                        TextSpan(
                          text: 'Artist Name',
                          style: TextStyle(
                            color: Colors.black,
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
          Divider(indent: 20, endIndent: 20),
          SizedBox(
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
          Divider(indent: 20, endIndent: 20, height: 30),
          SizedBox(
            width: size.width * 0.9,
            height: size.height * 0.05,
            child: Column(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      double newPosition =
                          (details.localPosition.dx / (size.width * 0.9))
                              .clamp(0.0, 1.0);
                      currentDuration = Duration(
                          seconds:
                              (newPosition * totalDuration.inSeconds).toInt());
                      audioPlayer.seek(currentDuration);
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: size.width * 0.9,
                        height: size.height * 0.0105,
                        decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: (1 -
                                currentDuration.inSeconds /
                                    totalDuration.inSeconds) *
                            size.width *
                            0.9,
                        child: Container(
                          height: size.height * 0.011,
                          decoration: BoxDecoration(
                            color: Color(0xff3F3F3F),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(currentDuration),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Spacer(),
                    Text(
                      formatDuration(totalDuration),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: SvgPicture.asset('assets/icons/rewind.svg'),
                onPressed: _previousMusic,
              ),
              // 정지 버튼
              IconButton(
                icon: isPlaying
                    ? Icon(Icons.pause, size: 75, color: Colors.black)
                    : Icon(Icons.play_arrow, size: 75, color: Colors.black),
                onPressed: isPlaying ? _pauseMusic : _resumeMusic,
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/fast_forward.svg'),
                onPressed: _nextMusic,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
