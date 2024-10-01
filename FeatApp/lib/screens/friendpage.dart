import 'package:flutter/material.dart';
import 'package:feat/utils/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:feat/utils/saveId.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  List<String?> friends = [];// 검색된 친구 목록 저장
  List<String?> searchResults = [];  // 검색된 유저 목록 저장
 
  String searchQuery = "";
  bool isSearching = false; // 검색 상태를 확인하는 변수
  String? userId;

  Future<void> loadUserId() async {
    userId = await saveId();
    // userId를 사용하여 추가 작업 수행
    print('User ID: $userId');
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
    loadUserId();
  }

  // 기존 친구 목록을 불러오는 함수
  Future<void> loadFriends() async {
    final url = Uri.parse('http://172.24.4.212:8080/search/');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          friends = List<String?>.from(
              jsonDecode(response.body));
          print(friends);
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // 검색어에 맞는 모든 유저를 불러오는 함수
  Future<void> searchUsers(String query) async {
    final url = Uri.parse('http://172.24.4.212:8080/searchUsers/');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query}),
      );

      if (response.statusCode == 200) {
        setState(() {
          searchResults = List<String?>.from(jsonDecode(response.body));
          print(searchResults);
        });
      } else {
        throw Exception('Failed to search users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.white,
        appBar: buildAppBar(context, '친구'),
        body: Column(
          children: [
            Search(
                onSearch: (query) {
                  setState(() {
                    isSearching = query.isNotEmpty;
                    searchQuery = query;
                  });
                  if (isSearching) {
                    searchUsers(query);
                  } else {
                    loadFriends();
                  }
                },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: isSearching ? searchResults.length : friends.length,
                itemBuilder: (context, index) {
                  final displayedList = isSearching ? searchResults : friends;
                  return FriendComponent(friendName: displayedList[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


class Search extends StatefulWidget {
  final Function(String) onSearch;

  Search({super.key, required this.onSearch});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: size.width * 0.9,
        height: 50,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey,
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Icon(Icons.search, color: Colors.white70),
            ),
            SizedBox(
              width: size.width * 0.6,
              height: 70,
              child: TextField(
                onChanged: (text) {
                  widget.onSearch(text);
                },
                decoration: InputDecoration(
                  hintText: '친구 추가 또는 검색',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white70),
                cursorColor: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FriendComponent extends StatelessWidget {
  final String? friendName;

  FriendComponent({super.key, this.friendName});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'calendar');
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(25, 0, 20, 0),
        width: 450,
        height: 130,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
            ),
            SizedBox(
                width: 200,
                height: 100,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child:Container(
                          margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
                          child: Text('친구1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: Text('ID', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
