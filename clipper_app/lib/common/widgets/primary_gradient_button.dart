import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class PrimaryGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;

  const PrimaryGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 50,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.primaryGradient,
        color: onPressed == null ? Colors.white24 : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          child: child,
        ),
      ),
    );
  }
}
