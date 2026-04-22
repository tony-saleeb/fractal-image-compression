import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(text),
            ],
          )
        : Text(text);

    if (isOutlined) {
      return isFullWidth
          ? SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onPressed,
                child: buttonChild,
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              child: buttonChild,
            );
    } else {
      return isFullWidth
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                child: buttonChild,
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: buttonChild,
            );
    }
  }
}

