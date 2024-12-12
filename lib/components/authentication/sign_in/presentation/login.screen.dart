import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/utils/extensions.dart';
import 'package:mentor/shared/utils/validator.dart';
import 'package:mentor/shared/views/button.dart';
import 'package:mentor/shared/views/input_field.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final validator = Validator();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  bool _passwordVisible = true;
  bool isChecked = false;

  @override
  void dispose() {
    super.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
  }

  bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  Future<void> login(BuildContext context) async {
    final userDataProvider = context.read<UserDataProvider>();

    if (!_formKey.currentState!.validate()) return;

    String parsed;
    try {
      String email = emailCtrl.text.trim();
      String password = passwordCtrl.text.trim();

      if (!isNullOrEmpty(email) && !isNullOrEmpty(password)) {
        final response = await http.post(
          Uri.parse('http://localhost:8080/auth/login'),
          headers: {
            "content-type": "application/json"
          },
          body: jsonEncode(<String, String>{
            'emailId': email,
            'password': password,
          })
        );

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
          context.go(AppRoutes.home);
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisibility =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                child: KeyboardDismissOnTap(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () => context.go(AppRoutes.home),
                              icon: Icon(Icons.arrow_back,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer)),
                          Text("Home", style: context.headlineSmall)
                        ],
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          Text('Welcome,', style: context.displayMedium),
                          Text('Sign in to continue!',
                              style: context.bodyMedium),
                          const SizedBox(
                            height: 20,
                          ),
                          formSignIn(context),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ))),
                    ])))),
    );
  }

  Widget formSignIn(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputField(
              controller: emailCtrl,
              validator: (value) {
                return validator.required(value, 'This field is required');
              },
              labelText: "Email Id",
              prefixIcon: const Icon(Icons.account_circle_outlined),
            ),
            const SizedBox(
              height: 20,
            ),
            InputField(
                controller: passwordCtrl,
                validator: (value) {
                  return validator.required(value, 'This field is required');
                },
                obscureText: _passwordVisible,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    )),
                labelText: 'Password'),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                Text("Remember me", style: context.titleSmall)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Forget password", style: context.bodySmall),
                TextButton(
                    onPressed: () => context.push(AppRoutes.forgetPassword),
                    child: Text('Recover now!',
                        style: TextStyle(color: context.colors.primary))),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            CustomButton(
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    login(context);
                  }
                },
                label: "Sign in"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Not a member!', style: context.bodyMedium),
                TextButton(
                    onPressed: () => context.push(AppRoutes.signup),
                    child: Text('Register Now!',
                        style: TextStyle(color: context.colors.primary))),
              ],
            ),
          ],
        ));
  }
}



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mentor/components/authentication/widgets/social_button.dart';
// import 'package:mentor/navigation/router.dart';
// import 'package:mentor/shared/utils/extensions.dart';
// import 'package:mentor/shared/utils/validator.dart';
// import 'package:mentor/shared/views/button.dart';
// import 'package:mentor/shared/views/divider_with_text.dart';
// import 'package:mentor/shared/views/input_field.dart';
// import 'package:mentor/provider/user_data_provider.dart';
// import 'package:provider/provider.dart';


// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final validator = Validator();
//   TextEditingController usernameCtrl = TextEditingController();
//   TextEditingController passwordCtrl = TextEditingController();
//   bool _passwordVisible = true;
//   bool isChecked = false;

//   var _isFormLoading = false;

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     usernameCtrl.dispose();
//     passwordCtrl.dispose();
//   }

//    bool isNullOrEmpty(String? value) {
//     return value == null || value.isEmpty;
//   }

//   Future<void> login(BuildContext context) async {

//     // Access UserDataProvider via context
//     final userDataProvider = context.read<UserDataProvider>();

//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isFormLoading = true;
//     });

//     String parsed;

//     try {
//       String userName = usernameCtrl.text.trim();
//       String password = passwordCtrl.text.trim();

//       if (!isNullOrEmpty(userName) && !isNullOrEmpty(password)) {
//         final response = await http.post(
//           Uri.parse('http://localhost:8080/auth/login'),
//             headers: {
//               "content-type": "application/json"
//             },
//             body: jsonEncode(<String, String>{
//               'userName': userName,
//               'password': password,
//             })
//           );

//           parsed = response.body;
//         if (response.statusCode == 200) {
//           Map<String, dynamic> map = jsonDecode(parsed);

//           String usertoken = map['token'];
//           String userid = map['userId'].toString();
          
//           await userDataProvider.setUserDataAsync(
//             usertoken: usertoken,
//             userid: userid,
//           );
//           context.go(AppRoutes.home);
//         }
//         } else {
//           throw Exception('Invalid credentials');
//         }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       setState(() {
//         _isFormLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isKeyboardVisibility =
//         MediaQuery.of(context).viewInsets.bottom > 0;

//     return Scaffold(
//         body: SafeArea(
//             child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
//                 child: KeyboardDismissOnTap(
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                       Row(
//                         children: [
//                           IconButton(
//                               onPressed: () => context.go(AppRoutes.home),
//                               icon: Icon(Icons.arrow_back,
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .onSecondaryContainer)),
//                           Text("Home", style: context.headlineSmall)
//                         ],
//                       ),
//                       Expanded(
//                           child: SingleChildScrollView(
//                               child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             height: 40,
//                           ),
//                           if (!isKeyboardVisibility) ...[
//                             Center(
//                               child: Image.asset(
//                                 "assets/images/sign_in.jpg",
//                                 fit: BoxFit.contain,
//                                 width: MediaQuery.of(context).size.width * 0.5,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 40,
//                             ),
//                           ],
//                           Text('Welcome,', style: context.displayMedium),
//                           Text('Sign in to continue!',
//                               style: context.bodyMedium),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           formSignIn(context),
//                           const SizedBox(
//                             height: 16,
//                           ),
//                           if (!isKeyboardVisibility) ...[
//                             socialSignIn(context),
//                           ]
//                         ],
//                       ))),
//                     ])))));
//   }

//   Widget formSignIn(BuildContext context) {
//     return Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             InputField(
//               controller: usernameCtrl,
//               validator: (value) {
//                 return validator.required(value, 'This field is required');
//               },
//               labelText: "Username",
//               prefixIcon: const Icon(Icons.account_circle_outlined),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             InputField(
//                 controller: passwordCtrl,
//                 validator: (value) {
//                   return validator.required(value, 'This field is required');
//                 },
//                 obscureText: _passwordVisible,
//                 prefixIcon: const Icon(Icons.lock_outline_rounded),
//                 suffixIcon: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         _passwordVisible = !_passwordVisible;
//                       });
//                     },
//                     icon: Icon(
//                       _passwordVisible
//                           ? Icons.visibility_off_outlined
//                           : Icons.visibility_outlined,
//                       size: 18,
//                     )),
//                 labelText: 'Password'),
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               children: [
//                 Checkbox(
//                   checkColor: Colors.white,
//                   value: isChecked,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       isChecked = value!;
//                     });
//                   },
//                 ),
//                 Text("Remember me", style: context.titleSmall)
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text("Forget password", style: context.bodySmall),
//                 TextButton(
//                     onPressed: () => context.push(AppRoutes.forgetPassword),
//                     child: Text('Recover now!',
//                         style: TextStyle(color: context.colors.primary))),
//               ],
//             ),
//             const SizedBox(
//               height: 24,
//             ),
//             CustomButton(
//                 minWidth: MediaQuery.of(context).size.width,
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     login(context);
//                   }
//                 },
//                 label: "Sign in"),
//           ],
//         ));
//   }

//   Widget socialSignIn(BuildContext context) {
//     return Column(
//       children: [
//         DividerWithText(
//             label: "Or continue with",
//             styleLabel: context.bodySmall,
//             colorDivider: Theme.of(context).colorScheme.tertiary),
//         const SizedBox(
//           height: 16,
//         ),
//         SocialButton(
//           text: "Continue with Google",
//           imgPath: "assets/images/gg.png",
//           onPressed: () => {},
//         ),
//         const SizedBox(
//           width: 16,
//         ),
//         SocialButton(
//           text: "Continue with Apple",
//           imgPath: "assets/images/ios.png",
//           onPressed: () => {},
//         ),
//         const SizedBox(
//           width: 16,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Not a member!', style: context.bodyMedium),
//             TextButton(
//                 onPressed: () => context.push(AppRoutes.signup),
//                 child: Text('Register Now!',
//                     style: TextStyle(color: context.colors.primary))),
//           ],
//         )
//       ],
//     );
//   }
// }
