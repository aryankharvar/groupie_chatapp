import 'package:shared_preferences/shared_preferences.dart';

class AppPref {
  static late SharedPreferences _preferences;
  static String userId="user_id";
  static String userName="user_name";
  static String userEmail="user_email";
  static String userProfileImage="user_Profile_Image";

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future<bool> setIsUserLogin(bool value) async =>
      await _preferences.setBool("isUserLogin", value);

  static bool? getIsUserLogin() => _preferences.getBool("isUserLogin");


  static Future<bool> setUserId(String value) async =>
      await _preferences.setString(userId, value);

  static String? getUserId() => _preferences.getString(userId);


  static Future<bool> setUserName(String value) async =>
      await _preferences.setString(userName, value);

  static String? getUserName() => _preferences.getString(userName);

  static Future<bool> setUserEmail(String value) async =>
      await _preferences.setString(userEmail, value);

  static String? getUserEmail() => _preferences.getString(userEmail);

  static Future<bool> setUserProfileImage(String value) async =>
      await _preferences.setString(userProfileImage, value);

  static String? getUserProfileImage() => _preferences.getString(userProfileImage);

  static void removeAll() async {
    _preferences.remove(userId);
    _preferences.remove(userName);
    _preferences.remove(userEmail);
    _preferences.remove(userProfileImage);
    setIsUserLogin(false);
  }
}