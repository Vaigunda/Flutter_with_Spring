import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../navigation/router.dart';
import '../../provider/user_data_provider.dart';

class TokenService {

  Future<void> checkToken(String usertoken, BuildContext context) async {
    final userDataProvider = context.read<UserDataProvider>();

        await userDataProvider.setUserDataAsync(
          usertoken: '',
          userid: '',
          name: '',
          usertype: '',
        );
        // Token is expired
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your token is expired!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        context.go(AppRoutes.signin);
  }
}
