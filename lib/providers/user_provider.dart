import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  // Cek apakah user sudah pernah isi data
  bool get hasData => _userProfile != null;

  // Load data dari memori HP saat aplikasi dibuka
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user_profile_local');

    if (userDataString != null) {
      final Map<String, dynamic> userMap = jsonDecode(userDataString);
      _userProfile = UserProfile.fromJson(userMap);
      notifyListeners();
    }
  }

  // Simpan data input user (Update data)
  Future<void> saveUserData(UserProfile profile) async {
    _userProfile = profile;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String userDataString = jsonEncode(profile.toJson());
    await prefs.setString('user_profile_local', userDataString);
  }

  // Hapus data (jika diperlukan fitur reset)
  Future<void> clearUserData() async {
    _userProfile = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile_local');
  }
}