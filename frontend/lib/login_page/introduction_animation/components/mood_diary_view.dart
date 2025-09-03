import 'package:flutter/material.dart';

class MoodDiaryView extends StatelessWidget {
  final AnimationController animationController;

  const MoodDiaryView({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    ));
    return SlideTransition(
      position: firstHalfAnimation,
      child: const Center(
        child: Text('Mood Diary View'),  // Placeholder content
      ),
    );
  }
}
