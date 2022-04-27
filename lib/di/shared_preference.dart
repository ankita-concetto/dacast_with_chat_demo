import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference extends SharedPreferenceRepository {
  SharedPreferences? _pref;
  final String _authorizedToken = "authorized_token";
  final String _userDetails = "user_details";
  final String _isIntroScreenVisible = "intro_screen_visible";

  @override
  Future<bool?> clearData() async {
    return _pref?.remove(_userDetails);
  }

  initPreference() async {
    _pref = await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getAuthorizedToken() async {
    final _prefs = await SharedPreferences.getInstance();
    String token = _prefs.getString(_authorizedToken) ?? "";
    return token == "" ? null : "Bearer $token";
  }

  @override
  Future<bool> setAuthorizedToken(String? authToken) async {
    final _prefs = await SharedPreferences.getInstance();
    return _prefs.setString(_authorizedToken, authToken!);
  }
}

abstract class SharedPreferenceRepository {
  Future<bool?> clearData();

  Future<bool> setAuthorizedToken(String? authToken);

  Future<String?> getAuthorizedToken();

}
