import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mentor/navigation/router.dart';
import 'dart:convert';

import 'package:mentor/shared/utils/extensions.dart';
import 'package:mentor/shared/utils/validator.dart';
import 'package:mentor/shared/views/button.dart';
import 'package:mentor/shared/views/input_field.dart';
import 'package:mentor/terms_condition.dart';

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
  TextEditingController confirmPasswordCtrl = TextEditingController();
  TextEditingController otpCtrl = TextEditingController();

  final FocusNode _genderFocusNode = FocusNode();

  bool _passwordVisible = true;
  bool isChecked = false;
  bool isterm = false;

  late String otp;
  bool isOtpVerified = false;
  bool isLoading = false;
  bool isVerify = false;

  @override
  void dispose() {
    super.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    confirmPasswordCtrl.dispose();
    ageCtrl.dispose();
    genderCtrl.dispose();
    _genderFocusNode.dispose();
  }

  void _handleEnterKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (_formKey.currentState!.validate()) {
        _signUp();
      }
    }
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
                                      padding: const EdgeInsets.all(16),
                                      child: formSignUp(context),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: SizedBox(
                                  height: 600,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        'assets/images/signup.png',
                                        fit: BoxFit.cover,
                                      ),
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
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            Center(
                              child: Text(
                                'Sign up to get started!',
                                style: Theme.of(context).textTheme.bodyMedium,
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
      child: RawKeyboardListener(
        focusNode: _genderFocusNode,
        onKey: _handleEnterKey,
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
              controller: confirmPasswordCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordCtrl.text) {
                  return 'Passwords do not match';
                }
                return null; // Validation passed
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
                ),
              ),
              labelText: 'Confirm Password',
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
                  return 'Please enter an email address';
                }
                // Email validation using regex
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null; // input is valid
              },
              keyboardType: TextInputType.emailAddress,
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
                      onPressed: isLoading ? () {} : () => sendOTP(emailCtrl.text),
                      label: isLoading ? 'Sending...' : 'Send OTP',
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
                        if (otpCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('OTP is required'),
                              backgroundColor: Colors.red,
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                        } else {
                          verifyOTP(otpCtrl.text);
                        }
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
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  value: isterm,
                  onChanged: (bool? value) {
                    setState(() {
                      isterm = value!;
                    });
                  },
                ),
                Row(
                  children: [
                    Text("I accept the", style: context.titleSmall),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TermsAndConditionsPage()));
                      },
                      child: const Text(
                        "Terms and Conditions",
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: CustomButton(
                borderRadius: 4,
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!isterm) {
                      // If not, show an alert or a message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You must accept the Terms and Conditions to sign up.'),
                          backgroundColor: Colors.red,
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                      return;
                    }
                    _signUp();
                  }
                },
                label: "Sign up",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to send sign-up request to API
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Prepare the data to send as JSON
    final body = jsonEncode({
      'userName': usernameCtrl.text,
      'password': passwordCtrl.text,
      'name': nameCtrl.text,
      'emailId': emailCtrl.text,
      'age': ageCtrl.text.isEmpty ? '0' : ageCtrl.text, // Optional field
      'gender': genderCtrl.text.isEmpty
          ? 'Not Specified'
          : genderCtrl.text, // Optional field
    });

    if (isOtpVerified) {
      final url = Uri.parse('http://localhost:8080/api/auth/sign-up');
      final response = await http.post(
        url,
        headers: {
          "Content-Type":
              "application/json", // Make sure content type is correct
        },
        body: body, // Send the JSON string as the body
      );

      if (response.statusCode == 200) {
        if (response.body == 'Email already Exists') {
          // Email already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email already Exists!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (response.statusCode == 201) {
        // Sign up successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign up successful!"),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.signin);
      } else {
        // Handle error, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign up failed! Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Verification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Verify Your Email OTP"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sendOTP(String email) async {
    // Email validation using regex
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/api/auth/mail/verify/$email'));

      if (response.statusCode == 200) {
        var parsed = response.body;
        Map<String, dynamic> map = jsonDecode(parsed);
        otp = map['data'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP is sent successfully to your email.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send email, please check your Email ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void verifyOTP(String verifyOTP) {
    // if (verifyOTP.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const Snackbar(
    //       content: Text('Please click "Send OTP".'),
    //       backgroundColor: Colors.red,
    //     )
    //   )
    // }
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
