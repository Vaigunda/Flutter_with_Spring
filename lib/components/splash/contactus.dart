import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/utils/validator.dart';
import 'package:mentor/shared/views/input_field.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../../../../constants/ui.dart';

class Contactus extends StatefulWidget {
  const Contactus({super.key});

  @override
  State<Contactus> createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  final _formKey = GlobalKey<FormState>();
  final validator = Validator();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _passwordVisible = true;
  bool isChecked = false;
  bool isTwoColumn = false;

  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    _passwordFocusNode.dispose();
  }

  bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  Future<void> login(BuildContext context) async {
    final userDataProvider = context.read<UserDataProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    String parsed;
    try {
      String email = emailCtrl.text.trim();
      String password = passwordCtrl.text.trim();

      if (!isNullOrEmpty(email) && !isNullOrEmpty(password)) {
        final response =
            await http.post(Uri.parse('http://localhost:8080/api/auth/login'),
                headers: {"content-type": "application/json"},
                body: jsonEncode(<String, String>{
                  'emailId': email,
                  'password': password,
                }));

        parsed = response.body;
        if (response.statusCode == 200) {
          Map<String, dynamic> map = jsonDecode(parsed);

          String usertoken = map['token'];
          String userid = map['userId'].toString();
          String name = map['name'];
          String usertype = map['userType'];

          await userDataProvider.setUserDataAsync(
            usertoken: usertoken,
            userid: userid,
            name: name,
            usertype: usertype,
          );
          context.go(AppRoutes.landing);
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password. Please Check!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleEnterKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (_formKey.currentState!.validate()) {
        login(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      isTwoColumn = constraints.maxWidth > 800;

      return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                    child: KeyboardDismissOnTap(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.go(AppRoutes.landing),
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                          isTwoColumn
                              ? Padding(
                                  padding: const EdgeInsets.all(60),
                                  child: Material(
                                    elevation: 4,
                                    child: Card(
                                      color: Colors.transparent,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: formSignIn(context),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/contact_us.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : formSignIn(context),
                        ]))))),
      );
    }));
  }

  Widget formSignIn(BuildContext context) {
    return Form(
        key: _formKey,
        child: RawKeyboardListener(
            focusNode: _passwordFocusNode,
            onKey: _handleEnterKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      buildCustomTextRow(),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'Contact Us',
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: "Lobster",
                              fontWeight: FontWeight.w400,
                              height: 62 / 48,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'For any Queries you can contact us!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputField(
                    controller: emailCtrl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    labelText: "Name",
                    prefixIcon: const Icon(HugeIcons.strokeRoundedUser),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  InputField(
                      controller: passwordCtrl,
                      validator: (value) {
                        return validator.required(
                            value, 'This field is required');
                      },
                      labelText: 'Age'),
                  const SizedBox(
                    height: 20,
                  ),
                  InputField(
                    controller: emailCtrl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      // Email validation using regex
                      final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null; // input is valid
                    },
                    keyboardType: TextInputType.emailAddress,
                    labelText: "Email Id",
                    prefixIcon: const Icon(HugeIcons.strokeRoundedUser),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputField(
                    maxLines: 2,
                      controller: passwordCtrl,
                      validator: (value) {
                        return validator.required(
                            value, 'This field is required');
                      },
                      labelText: 'Message'),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 18),
                      backgroundColor: Colors.blue, // Set background color
                      foregroundColor: Colors.white, // Set text color
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        isLoading ? null : login(context);
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )));
  }
}
