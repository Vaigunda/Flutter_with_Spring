import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mentor/provider/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../../navigation/router.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;

  const EditUserScreen({super.key, required this.userId});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController ageCtrl = TextEditingController();
  TextEditingController genderCtrl = TextEditingController();
  //TextEditingController passwordCtrl = TextEditingController();
  TextEditingController userNameCtrl = TextEditingController(); // New userName field controller

  bool isLoading = true;
  var provider;

  late String usertoken;

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/user/profile/${widget.userId}'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $usertoken',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        setState(() {
          nameCtrl.text = map['name'];
          emailCtrl.text = map['emailId'];
          ageCtrl.text = map['age'].toString();
          genderCtrl.text = map['gender'];
          userNameCtrl.text = map['userName']; // Set the userName value
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch user profile");
      }
    } catch (error) {
      print("Error fetching profile: $error");
    }
  }

  Future<void> updateUserProfile() async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/user/update-user/${widget.userId}'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $usertoken',
        },
        body: jsonEncode({
          'name': nameCtrl.text,
          'emailId': emailCtrl.text,
          'age': ageCtrl.text.isEmpty ? '0' : ageCtrl.text,
          'gender': genderCtrl.text.isEmpty ? 'Not Specified' : genderCtrl.text,
          //'password': passwordCtrl.text.isNotEmpty ? passwordCtrl.text : null, // Include password if not empty
          'userName': userNameCtrl.text, // Include userName in the update request
        }),
      );

      if (response.statusCode == 200) {
         // Successfully updated
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.home);
      } else {
        throw Exception("Failed to update user");
      }
    } catch (error) {
      print("Error updating user: $error");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error updating user")));
    }
  }

  @override
  void initState() {
    super.initState();
    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: "Email ID"),
                    ),
                    TextFormField(
                      controller: ageCtrl,
                      decoration: const InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: genderCtrl,
                      decoration: const InputDecoration(labelText: "Gender"),
                    ),
                    TextFormField(
                      controller: userNameCtrl, // New userName field in the form
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    /*TextFormField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(labelText: "Password (Leave empty to keep current password)"),
                      obscureText: true,
                    ),*/
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateUserProfile,
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
