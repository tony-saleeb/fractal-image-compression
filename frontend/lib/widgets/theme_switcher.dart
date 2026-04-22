import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ThemeSwitcher extends StatefulWidget {
  final Widget child;

  const ThemeSwitcher({super.key, required this.child});

  static ThemeSwitcherState of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeSwitcherState>()!;
  }

  @override
  State<ThemeSwitcher> createState() => ThemeSwitcherState();
}

class ThemeSwitcherState extends State<ThemeSwitcher> {
  final GlobalKey _globalKey = GlobalKey();
  ui.Image? _image;
  bool _isSwitching = false;

  Future<void> changeTheme(VoidCallback updateTheme) async {
    // 1. Capture the current screen
    final boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null && boundary.debugNeedsPaint == false) {
      final image = await boundary.toImage(
        pixelRatio: View.of(context).devicePixelRatio,
      );
      setState(() {
        _image = image;
        _isSwitching = true;
      });
    }

    // 2. Update the theme (rebuilds the app with new theme)
    updateTheme();

    // 3. Fade out the old image
    if (_image != null) {
      // Small delay to ensure the new theme frame is ready
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose the captured image to prevent memory leak
    _image?.dispose();
    _image = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          RepaintBoundary(key: _globalKey, child: widget.child),
          if (_image != null)
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                opacity: _isSwitching ? 1.0 : 0.0,
                onEnd: () {
                  // Dispose image when animation completes
                  _image?.dispose();
                  setState(() {
                    _image = null;
                  });
                },
                child: RawImage(image: _image, fit: BoxFit.cover),
              ),
            ),
        ],
      ),
    );
  }
}
