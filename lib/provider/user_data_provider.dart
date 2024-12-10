import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentor/constants/values.dart';

class UserDataProvider extends ChangeNotifier {
  var _userid = '';
  var _usertoken = '';
  var _name = ''; // Added Name field

  String get userid => _userid;
  String get usertoken => _usertoken;
  String get name => _name; // Getter for Name

  Future<void> loadAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    _userid = sharedPref.getString(StorageKeys.userid) ?? '';
    _usertoken = sharedPref.getString(StorageKeys.usertoken) ?? '';
    _name = sharedPref.getString(StorageKeys.name) ?? ''; // Load username

    notifyListeners();
  }

  Future<void> setUserDataAsync({
    String? userid,
    String? usertoken,
    String? name, // Added username parameter
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

    if (name != null && name != _name) { // Handle name updates
      _name = name;
      await sharedPref.setString(StorageKeys.name, _name);
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
    await sharedPref.remove(StorageKeys.name); // Clear name as well

    _userid = '';
    _usertoken = '';
    _name = ''; // Clear name

    notifyListeners();
  }

  bool isUserLoggedIn() {
    return _userid.isNotEmpty;
  }
}
