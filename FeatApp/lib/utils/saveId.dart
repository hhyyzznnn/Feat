import 'package:shared_preferences/shared_preferences.dart';

Future<String?> saveId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}
