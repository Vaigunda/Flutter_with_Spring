import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/utils/extensions.dart';
import 'package:mentor/shared/views/button.dart';
import 'package:mentor/shared/views/pin_code.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCodeScreen extends StatefulWidget {
  VerifyCodeScreen({super.key, required this.email});
  String email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController codeCtrl = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisibility =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow layout to resize when the keyboard is visible
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
          child: KeyboardDismissOnTap(
            child: SingleChildScrollView( // Wrap content with a scrollable widget
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Main Content
                  if (!isKeyboardVisibility) ...[
                    Center(
                      child: Image.asset(
                        "assets/images/enter_otp.png",
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.7,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                  Text(
                    'Enter the verified code',
                    style: context.titleLarge,
                  ),
                  Text(
                    'We just sent you a verified code via an email ${widget.email}',
                    style: context.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  // Form Section
                  formVerifyCode(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

  Widget formVerifyCode(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PinCode(controller: codeCtrl, errorController: errorController!),
            const SizedBox(
              height: 40,
            ),
            CustomButton(
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //TODO: Logic here
                    context.push(AppRoutes.newPassword);
                  }
                },
                label: "Next"),
          ],
        ));
  }
}
