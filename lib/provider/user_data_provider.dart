import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentor/constants/values.dart';

class UserDataProvider extends ChangeNotifier {
  var _userid = '';
  var _usertoken = '';

  String get userid => _userid;

  String get usertoken => _usertoken;

  Future<void> loadAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    _userid = sharedPref.getString(StorageKeys.userid) ?? '';
    _usertoken = sharedPref.getString(StorageKeys.usertoken) ?? '';

    notifyListeners();
  }

  Future<void> setUserDataAsync({
    String? userid,
    String? usertoken,
  }) async {
    final sharedPref = await SharedPreferences.getInstance();
    var shouldNotify = false;

    if (userid != null && userid != _userid) {
      _userid = userid;

      await sharedPref.setString(StorageKeys.userid, _userid);

      shouldNotify = true;
    }

    if (usertoken != null && usertoken != _usertoken) {
      _usertoken = usertoken;

      await sharedPref.setString(StorageKeys.usertoken, _usertoken);

      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> clearUserDataAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    await sharedPref.remove(StorageKeys.userid);
    await sharedPref.remove(StorageKeys.usertoken);

    _userid = '';
    _usertoken = '';

    notifyListeners();
  }

  bool isUserLoggedIn() {
    return _userid.isNotEmpty;
  }
}