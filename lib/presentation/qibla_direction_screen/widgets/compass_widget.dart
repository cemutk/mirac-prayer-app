import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Compass widget that displays Qibla direction with rotating arrow
class CompassWidget extends StatelessWidget {
  final double qiblahDirection;
  final double deviceDirection;
  final bool isAccurate;
  final bool isStatic;
  final bool showKaabaIcon;

  const CompassWidget({
    super.key,
    required this.qiblahDirection,
    required this.deviceDirection,
    this.isAccurate = true,
    this.isStatic = false,
    this.showKaabaIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate the angle difference between device and Qibla
    double angleDifference = qiblahDirection - deviceDirection;

    // Normalize to -180 to 180 range
    if (angleDifference > 180) {
      angleDifference -= 360;
    } else if (angleDifference < -180) {
      angleDifference += 360;
    }

    // Check if aligned (within 3 degrees for stricter alignment)
    final isAligned = angleDifference.abs() <= 3;

    return Center(
      child: SizedBox(
        width: 70.w,
        height: 70.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),

            // Compass markings
            CustomPaint(
              size: Size(70.w, 70.w),
              painter: _CompassMarkingsPainter(
                primaryColor: theme.colorScheme.primary,
                secondaryColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),

            // Kaaba Icon at Qibla direction (on the compass circle)
            if (showKaabaIcon)
              AnimatedRotation(
                turns:
                    isStatic ? -qiblahDirection / 360 : -angleDifference / 360,
                duration: const Duration(milliseconds: 200),
                child: Transform.translate(
                  offset: Offset(0, -28.w), // Position on compass edge
                  child: _buildKaabaIcon(theme, isAligned),
                ),
              ),

            // Rotating Qibla arrow
            AnimatedRotation(
              turns: isStatic ? -qiblahDirection / 360 : -angleDifference / 360,
              duration: const Duration(milliseconds: 200),
              child: CustomPaint(
                size: Size(60.w, 60.w),
                painter: _QiblaArrowPainter(
                  color: isAligned ? Colors.green : theme.colorScheme.primary,
                  isAligned: isAligned,
                ),
              ),
            ),

            // Center dot
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),

            // Direction text at top
            Positioned(
              top: 2.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'N',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Kaaba icon widget
  Widget _buildKaabaIcon(ThemeData theme, bool isAligned) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              isAligned ? Colors.green : const Color(0xFFFFD700), // Gold color
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isAligned
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.amber.withValues(alpha: 0.3),
            blurRadius: isAligned ? 15 : 8,
            spreadRadius: isAligned ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Golden horizontal stripe (Kiswa pattern)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.8),
                    const Color(0xFFFFA500),
                    const Color(0xFFFFD700).withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Golden vertical stripe
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.8),
                    const Color(0xFFFFA500),
                    const Color(0xFFFFD700).withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          // Decorative dots at corners (Kiswa ornaments)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for compass markings (degrees and cardinal directions)
class _CompassMarkingsPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _CompassMarkingsPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw degree markings
    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;

      paint.color = isMajor ? primaryColor : secondaryColor;
      paint.strokeWidth = isMajor ? 3 : 1;

      final startRadius = isMajor ? radius - 15 : radius - 10;
      final endRadius = radius - 5;

      final start = Offset(
        center.dx + startRadius * math.sin(angle),
        center.dy - startRadius * math.cos(angle),
      );

      final end = Offset(
        center.dx + endRadius * math.sin(angle),
        center.dy - endRadius * math.cos(angle),
      );

      canvas.drawLine(start, end, paint);
    }

    // Draw outer circle
    paint
      ..color = secondaryColor
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for Qibla direction arrow
class _QiblaArrowPainter extends CustomPainter {
  final Color color;
  final bool isAligned;

  _QiblaArrowPainter({
    required this.color,
    required this.isAligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw arrow pointing up (north)
    final arrowPath = Path();

    // Arrow tip
    arrowPath.moveTo(center.dx, size.height * 0.15);

    // Right side
    arrowPath.lineTo(center.dx + 20, size.height * 0.35);
    arrowPath.lineTo(center.dx + 8, size.height * 0.35);
    arrowPath.lineTo(center.dx + 8, size.height * 0.65);

    // Bottom right
    arrowPath.lineTo(center.dx + 15, size.height * 0.72);
    arrowPath.lineTo(center.dx, size.height * 0.68);

    // Bottom left
    arrowPath.lineTo(center.dx - 15, size.height * 0.72);
    arrowPath.lineTo(center.dx - 8, size.height * 0.65);

    // Left side
    arrowPath.lineTo(center.dx - 8, size.height * 0.35);
    arrowPath.lineTo(center.dx - 20, size.height * 0.35);

    arrowPath.close();

    canvas.drawPath(arrowPath, paint);

    // Add white outline for better visibility
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(arrowPath, outlinePaint);

    // Add enhanced glow effect when aligned
    if (isAligned) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawPath(arrowPath, glowPaint);

      // Secondary outer glow
      final outerGlowPaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

      canvas.drawPath(arrowPath, outerGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
