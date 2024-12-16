import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mentor/navigation/router.dart';
import 'dart:convert';

import 'package:mentor/shared/utils/extensions.dart';
import 'package:mentor/shared/utils/validator.dart';
import 'package:mentor/shared/views/button.dart';
import 'package:mentor/shared/views/input_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final validator = Validator();
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController ageCtrl = TextEditingController();
  TextEditingController genderCtrl = TextEditingController();

  TextEditingController otpCtrl = TextEditingController();

  bool _passwordVisible = true;
  bool isChecked = false;

  late String otp;
  bool isOtpVerified = false;

  @override
  void dispose() {
    super.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    ageCtrl.dispose();
    genderCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisibility = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        title: const Center(
          child: Text(
            "Register",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: KeyboardDismissOnTap(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "M",
                        style: TextStyle(
                          fontSize: 52,
                          fontFamily: "Lobster",
                          fontWeight: FontWeight.w400, // Weight: 400
                          color: Color(0xFF4ABFE2),
                          height: 62 / 48,
                        ),
                      ),
                      Text(
                        "entorboosters",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          fontFamily: "Epilogue",
                          color: Color(0xFF4ABFE2),
                          height: 42 / 32,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          ".",
                          style: TextStyle(
                            fontSize: 62,
                            fontWeight: FontWeight.w900,
                            fontFamily: "Epilogue",
                            color: Color(0xFF4ABFE2),
                            height: 42 / 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Material(
                          elevation: 4,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Create Account,',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        'Sign up to get started!',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: formSignUp(context),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/images/register.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Create Account,',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                            ),
                            Center(
                              child: Text(
                                'Sign up to get started!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: formSignUp(context),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget formSignUp(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputField(
            controller: usernameCtrl,
            validator: (value) =>
                validator.required(value, 'This field is required'),
            labelText: "Username",
            prefixIcon: const Icon(Icons.person_2),
          ),
          const SizedBox(height: 20),
          InputField(
            controller: passwordCtrl,
            validator: (value) =>
                validator.required(value, 'This field is required'),
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
              ),
            ),
            labelText: 'Password',
          ),
          const SizedBox(height: 20),
          InputField(
            controller: nameCtrl,
            validator: (value) =>
                validator.required(value, 'This field is required'),
            labelText: "Full Name",
            prefixIcon: const Icon(Icons.person),
          ),
          const SizedBox(height: 20),
          InputField(
            controller: emailCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            labelText: "Email",
            prefixIcon: const Icon(Icons.email),
          ),
          const SizedBox(height: 20),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CustomButton(
                    borderRadius: 4,
                    onPressed: () {
                      sendOTP(emailCtrl.text);
                    },
                    label: 'Send OTP',
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 150.0,
                      child: InputField(
                        controller: otpCtrl,
                        labelText: 'OTP',
                      )),
                  const SizedBox(width: 10),
                  CustomButton(
                    borderRadius: 4,
                    onPressed: () {
                      verifyOTP(otpCtrl.text);
                    },
                    label: 'Verify OTP',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          InputField(
            controller: ageCtrl,
            labelText: "Age (Optional)",
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: genderCtrl.text.isEmpty ? null : genderCtrl.text,
            onChanged: (value) {
              setState(() {
                genderCtrl.text = value!;
              });
            },
            items: [
              const DropdownMenuItem(
                value: 'Male',
                child: Text('Male'),
              ),
              const DropdownMenuItem(
                value: 'Female',
                child: Text('Female'),
              ),
            ],
            decoration: const InputDecoration(
              labelText: "Gender (Optional)",
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
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
              Text("Remember me", style: context.titleSmall),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: CustomButton(
              borderRadius: 4,
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signUp();
                }
              },
              label: "Sign up",
            ),
          ),
        ],
      ),
    );
  }

  // Function to send sign-up request to API
  Future<void> _signUp() async {

    // Prepare the data to send as JSON
    final body = jsonEncode({
      'userName': usernameCtrl.text,
      'password': passwordCtrl.text,
      'name': nameCtrl.text,
      'emailId': emailCtrl.text,
      'age': ageCtrl.text.isEmpty ? '0' : ageCtrl.text, // Optional field
      'gender': genderCtrl.text.isEmpty ? 'Not Specified' : genderCtrl.text, // Optional field
    });

    if (isOtpVerified) {
      final url = Uri.parse('http://localhost:8080/auth/sign-up');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // Make sure content type is correct
        },
        body: body, // Send the JSON string as the body
      );

      if (response.statusCode == 200) {
        if (response.body == 'Email already Exists') {
          // Email already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email already Exists!"),
            backgroundColor: Colors.green,),
          );
        }
      } if (response.statusCode == 201) {
        // Sign up successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up successful!"),
          backgroundColor: Colors.green,),
        );
        context.go(AppRoutes.signin);
      } else {
        // Handle error, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up failed! Please try again."),
          backgroundColor: Colors.red,),
        );
      }
    } else {
      // Verification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Verify Your Email OTP"),
        backgroundColor: Colors.red,),
      );             
    }
  }

  Future<void> sendOTP(String email) async {
    final response = await http
        .get(Uri.parse('http://localhost:8080/auth/mail/verify/$email'));

    if (response.statusCode == 200) {
      var parsed = response.body;
      Map<String, dynamic> map = jsonDecode(parsed);

      otp = map['data'];

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP is sent Successfully to your mail.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send email, Please check your Email ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void verifyOTP(String verifyOTP) {
    if (otp == verifyOTP) {
      isOtpVerified = true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified successfully. Continue your Sign up!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mentor/components/authentication/widgets/social_button.dart';
// import 'package:mentor/navigation/router.dart';
// import 'package:mentor/shared/utils/extensions.dart';
// import 'package:mentor/shared/utils/validator.dart';
// import 'package:mentor/shared/views/button.dart';
// import 'package:mentor/shared/views/divider_with_text.dart';
// import 'package:mentor/shared/views/input_field.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final validator = Validator();
//   TextEditingController usernameCtrl = TextEditingController();
//   TextEditingController passwordCtrl = TextEditingController();
//   bool _passwordVisible = true;
//   bool isChecked = false;
//   @override
//   void dispose() {
//     super.dispose();
//     usernameCtrl.dispose();
//     passwordCtrl.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isKeyboardVisibility = MediaQuery.of(context).viewInsets.bottom > 0;
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
//                               onPressed: () => context.pop(),
//                               icon: Icon(Icons.arrow_back,
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .onSecondaryContainer)),
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
//                                 "assets/images/sign_up.png",
//                                 fit: BoxFit.contain,
//                                 width: MediaQuery.of(context).size.width * 0.5,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 40,
//                             ),
//                           ],
//                           Text('Create Account,', style: context.displayMedium),
//                           Text('Sign up to get started!',
//                               style: context.bodyMedium),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           formSignUp(context),
//                           const SizedBox(
//                             height: 16,
//                           ),
//                           if (!isKeyboardVisibility) ...[
//                             socialSignUp(context),
//                           ]
//                         ],
//                       ))),
//                     ])))));
//   }

//   Widget formSignUp(BuildContext context) {
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
//             const SizedBox(
//               height: 24,
//             ),
//             CustomButton(
//                 minWidth: MediaQuery.of(context).size.width,
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     //TODO: Logic here
//                   }
//                 },
//                 label: "Sign up"),
//           ],
//         ));
//   }

//   Widget socialSignUp(BuildContext context) {
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
//             Text('Already a member!', style: context.bodyMedium),
//             TextButton(
//                 onPressed: () => context.push(AppRoutes.signin),
//                 child: Text('Sign in',
//                     style: TextStyle(color: context.colors.primary))),
//           ],
//         )
//       ],
//     );
//   }
// }