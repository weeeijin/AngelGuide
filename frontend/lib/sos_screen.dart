import 'package:flutter/material.dart';
import 'dart:async';

class SosScreen extends StatefulWidget {
  const SosScreen({Key? key}) : super(key: key);

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  bool _sosTriggered = false;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isPressing) {
        setState(() {
          _sosTriggered = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SOS has been triggered!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressing = true;
      _sosTriggered = false;
    });
    _progressController.forward(from: 0);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressing = false;
    });
    if (!_sosTriggered) {
      _progressController.reverse();
    }
  }

  void _onTapCancel() {
    setState(() {
      _isPressing = false;
    });
    if (!_sosTriggered) {
      _progressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7EBE1),
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular progress
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CustomPaint(
                          painter: _SOSProgressPainter(
                            progress: _progressController.value,
                            triggered: _sosTriggered,
                          ),
                        ),
                      ),
                      // Cute main SOS button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _sosTriggered ? Colors.red : Colors.pinkAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Comic Sans MS', // Cute font
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Cute subtitle
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _sosTriggered
                    ? 'SOS Triggered!'
                    : 'Press and hold the SOS button for 3 seconds',
                style: TextStyle(
                  color: Colors.pink[700],
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Comic Sans MS',
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SOSProgressPainter extends CustomPainter {
  final double progress;
  final bool triggered;
  _SOSProgressPainter({required this.progress, required this.triggered});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..color = Colors.pink[100]!
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint fgPaint = Paint()
      ..color = triggered ? Colors.red : Colors.pinkAccent
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 6, bgPaint);

    // Draw progress arc
    double sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 6),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      fgPaint,
    );

    // If triggered, fill the circle
    if (triggered) {
      final Paint fillPaint = Paint()
        ..color = Colors.red.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 12, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SOSProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.triggered != triggered;
}
