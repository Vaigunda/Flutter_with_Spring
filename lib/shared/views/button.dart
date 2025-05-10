import 'package:flutter/material.dart';
import 'package:mentor/shared/shared.dart';

enum EButtonType { primary, secondary, outline }

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.minWidth,
    this.type = EButtonType.primary,
    this.padding,
    this.borderRadius = 0, 
  });

  String label;
  double? minWidth;
  bool disabled = false;
  EButtonType? type;
  WidgetStateProperty<EdgeInsetsGeometry?>? padding;
  void Function() onPressed;
  final double borderRadius; 

  @override
  Widget build(BuildContext context) {
    WidgetStatePropertyAll<Size>? minimumSize;
    if (minWidth != null) {
      minimumSize = WidgetStatePropertyAll<Size>(Size(minWidth!, 48));
    }

    // Common button styling
    ButtonStyle commonStyle = ButtonStyle(
      elevation: WidgetStateProperty.all(5),
      minimumSize: minimumSize,
      shadowColor: WidgetStatePropertyAll<Color>(Theme.of(context).colorScheme.surfaceTint),
    );

    // Primary ElevatedButton with conditional border radius
    if (type == EButtonType.primary) {
      return ElevatedButton(
        style: commonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(Theme.of(context).colorScheme.primary),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius), 
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: context.labelMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      );
    }

    if (type == EButtonType.secondary) {
      return ElevatedButton(
        style: commonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(Theme.of(context).colorScheme.primaryContainer),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius), 
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: context.labelMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return OutlinedButton(
      style: commonStyle.copyWith(
        side: WidgetStateProperty.all(
            BorderSide(color: Theme.of(context).colorScheme.primary)),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), 
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: context.labelMedium!
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

