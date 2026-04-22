import 'package:flutter/material.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;
  final Color? customColor;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
    this.customColor,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = widget.customColor ?? theme.colorScheme.primary;

    final Gradient? gradient =
        widget.isPrimary
            ? LinearGradient(
              colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : null;

    final Color backgroundColor =
        widget.isPrimary ? Colors.transparent : theme.colorScheme.surface;

    final Color textColor =
        widget.isPrimary ? Colors.white : theme.colorScheme.onSurface;

    final Border? border =
        widget.isPrimary
            ? null
            : Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            );

    return MouseRegion(
      onEnter: (_) {
        if (widget.onPressed != null) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        if (widget.onPressed != null) {
          setState(() => _isHovered = false);
          _controller.reverse();
        }
      },
      cursor:
          widget.onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: gradient,
              color: widget.isPrimary ? null : backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: border,
              boxShadow:
                  widget.isPrimary && widget.onPressed != null
                      ? [
                        BoxShadow(
                          color: primaryColor.withValues(
                            alpha: _isHovered ? 0.4 : 0.25,
                          ),
                          blurRadius: _isHovered ? 20 : 12,
                          offset: Offset(0, _isHovered ? 6 : 4),
                          spreadRadius: _isHovered ? 2 : 0,
                        ),
                      ]
                      : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: textColor, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
