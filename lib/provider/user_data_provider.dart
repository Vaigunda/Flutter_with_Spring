import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentor/constants/values.dart';

class UserDataProvider extends ChangeNotifier {
  var _userid = '';
  var _usertoken = '';
  var _username = ''; // Added username field

  String get userid => _userid;
  String get usertoken => _usertoken;
  String get username => _username; // Getter for username

  Future<void> loadAsync() async {
    final sharedPref = await SharedPreferences.getInstance();

    _userid = sharedPref.getString(StorageKeys.userid) ?? '';
    _usertoken = sharedPref.getString(StorageKeys.usertoken) ?? '';
    _username = sharedPref.getString(StorageKeys.username) ?? ''; // Load username

    notifyListeners();
  }

  Future<void> setUserDataAsync({
    String? userid,
    String? usertoken,
    String? username, // Added username parameter
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

    if (username != null && username != _username) { // Handle username updates
      _username = username;
      await sharedPref.setString(StorageKeys.username, _username);
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
    await sharedPref.remove(StorageKeys.username); // Clear username as well

    _userid = '';
    _usertoken = '';
    _username = ''; // Clear username

    notifyListeners();
  }

  bool isUserLoggedIn() {
    return _userid.isNotEmpty;
  }
}


// import 'package:flutter/widgets.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mentor/constants/values.dart';

// class UserDataProvider extends ChangeNotifier {
//   var _userid = '';
//   var _usertoken = '';
//   String _username = "";

//   String get userid => _userid;

//   String get usertoken => _usertoken;

//   String get username => _username;

//   Future<void> loadAsync() async {
//     final sharedPref = await SharedPreferences.getInstance();

//     _userid = sharedPref.getString(StorageKeys.userid) ?? '';
//     _usertoken = sharedPref.getString(StorageKeys.usertoken) ?? '';

//     notifyListeners();
//   }

//   Future<void> setUserDataAsync({
//     String? userid,
//     String? usertoken,
//   }) async {
//     final sharedPref = await SharedPreferences.getInstance();
//     var shouldNotify = false;

//     if (userid != null && userid != _userid) {
//       _userid = userid;

//       await sharedPref.setString(StorageKeys.userid, _userid);

//       shouldNotify = true;
//     }

//     if (usertoken != null && usertoken != _usertoken) {
//       _usertoken = usertoken;

//       await sharedPref.setString(StorageKeys.usertoken, _usertoken);

//       shouldNotify = true;
//     }

//     if (shouldNotify) {
//       notifyListeners();
//     }
//   }

//   Future<void> clearUserDataAsync() async {
//     final sharedPref = await SharedPreferences.getInstance();

//     await sharedPref.remove(StorageKeys.userid);
//     await sharedPref.remove(StorageKeys.usertoken);

//     _userid = '';
//     _usertoken = '';

//     notifyListeners();
//   }

//   bool isUserLoggedIn() {
//     return _userid.isNotEmpty;
//   }
// }