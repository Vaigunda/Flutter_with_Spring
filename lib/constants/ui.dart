import 'package:flutter/material.dart';

Widget buildCustomTextRow() {
  return const Padding(
    padding: EdgeInsets.only(bottom: 40),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          "m",
          style: TextStyle(
            fontSize: 48, // Size: 48px
            fontFamily: "Lobster", // Font Family: Lobster
            fontWeight: FontWeight.w400, // Weight: 400
            color: Color(0xFF4ABFE2), // Color: rgb(74, 191, 226)
            height: 62 / 48, // Line Height: 62px / 48px = ~1.29
          ),
        ),
        Text(
          "entorboosters",
          style: TextStyle(
            fontSize: 32, // Size: 32px
            fontWeight: FontWeight.w900, // Weight: 800
            fontFamily: "Epilogue", // Font Family: Epilogue, sans-serif
            color: Color(0xFF4ABFE2), // Color: rgb(74, 191, 226)
            height: 42 / 32, // Line Height: 42px / 32px = ~1.31
          ),
        ),
        Text(
          ".",
          style: TextStyle(
            fontSize: 72, // Font size for the dot
            fontWeight: FontWeight.w800, // Match the same weight as text
            fontFamily: "Epilogue", // Font Family
            color: Color(0xFF4ABFE2), // Match the color
            height: 1, // Default height
          ),
        ),
      ],
    ),
  );
}

int getCrossAxisCount(BuildContext context) {
  double width = MediaQuery.of(context).size.width;

  if (width > 1200) {
    return 4;
  } else if (width > 800) {
    return 2;
  } else {
    return 1;
  }
}
