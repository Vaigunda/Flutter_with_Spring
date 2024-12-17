import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/utils/extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      GoRouter.of(context).go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "m",
                    style: TextStyle(
                      fontSize: 48, // Size: 48px
                      fontFamily:
                          "Lobster", // Font Family: Lobster
                      fontWeight: FontWeight.w400, // Weight: 400
                      color: Color(
                          0xFF4ABFE2), // Color: rgb(74, 191, 226)
                      height: 62 /
                          48, // Line Height: 62px / 48px = ~1.29
                    ),
                  ),
                  Text(
                    "entorboosters",
                    style: TextStyle(
                      fontSize: 32, // Size: 32px
                      fontWeight: FontWeight.w700, // Weight: 800
                      fontFamily:
                          "Epilogue", // Font Family: Epilogue, sans-serif
                      color: Color(
                          0xFF4ABFE2), // Color: rgb(74, 191, 226)
                      height: 42 /
                          32, // Line Height: 42px / 32px = ~1.31
                    ),
                  ),
                  Text(
                    ".",
                    style: TextStyle(
                      fontSize: 72, // Font size for the dot
                      fontWeight: FontWeight
                          .w800, // Match the same weight as text
                      fontFamily: "Epilogue", // Font Family
                      color: Color(0xFF4ABFE2), // Match the color
                      height: 1, // Default height
                    ),
                  ),
                ],
              ),
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to",
                  style: context.headlineSmall,
                ),
                Text(
                  " Mentor Boosters",
                  style: context.displaySmall,
                ),
              ],
            ),
            Text(
              "Your Mentor partner in Progress",
              style: context.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
