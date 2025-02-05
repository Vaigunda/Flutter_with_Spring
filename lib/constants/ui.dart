import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

//Cross axix count

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



//Container styling
class HoverableContainer extends StatefulWidget {
  final Widget child;
  final BoxBorder? border;
  final BuildContext context;
  final Color? hoverColor; // Optional hover color
  final bool hover; // Optional hover flag (default: true)

  const HoverableContainer({
    super.key,
    required this.child,
    required this.context,
    this.border,
    this.hoverColor,
    this.hover = true, // Default value is true
  });

  @override
  _HoverableContainerState createState() => _HoverableContainerState();
}

class _HoverableContainerState extends State<HoverableContainer>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(bool hover) {
    if (!widget.hover) return; // Do nothing if hover is disabled
    setState(() {
      _isHovered = hover;
      if (_isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color hoverColor = widget.hoverColor ??
        (Get.isDarkMode
            ? Theme.of(context).primaryColorDark
            : Theme.of(context).primaryColorLight);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MouseRegion(
        cursor:
            widget.hover ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => _onEnter(true),
        onExit: (_) => _onEnter(false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? hoverColor
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withAlpha((0.2 * 255).round())
                            : Colors.grey.withAlpha((0.2 * 255).round()),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


//Delete dialog resuable funtion
Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required String itemName,
  required VoidCallback onConfirm,
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete $itemName?'),
        content: Text(
            'Are you sure you want to delete $itemName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$itemName has been deleted'),
                  duration:const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}