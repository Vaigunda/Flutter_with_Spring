import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/utils/extensions.dart';
import 'package:mentor/shared/utils/validator.dart';
import 'package:mentor/shared/views/button.dart';
import 'package:mentor/shared/views/input_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final validator = Validator();
  TextEditingController emailCtrl = TextEditingController();

  bool isTwoColumn = false;

  @override
  void dispose() {
    super.dispose();
    emailCtrl.dispose();
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
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text("Sign In", style: context.headlineSmall),
                  ],
                ),
                const SizedBox(height: 20),
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
                                child: formRecovery(context),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/forget_password.png',
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
                  : formRecovery(context),
            ]))))),
      );
    }));
  }


  Widget formRecovery(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    padding: EdgeInsets.only(bottom: 15),
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
              const SizedBox(
                height: 40,
              ),
              Text('Forgot your password?',
                  style: context.titleLarge),
              Text(
                  'Enter your email address below, we’ll send you a verify code.!',
                  style: context.bodySmall),
            InputField(
              controller: emailCtrl,
              validator: (value) {
                return validator.required(value, 'This field is required');
              },
              labelText: "Email",
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(
              height: 40,
            ),
            CustomButton(
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.push('${AppRoutes.verifyCode}/${emailCtrl.text}');
                  }
                },
                label: "Next"),
          ],
        ));
  }
}
