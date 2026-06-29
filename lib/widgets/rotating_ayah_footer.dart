import 'dart:async';
import 'package:flutter/material.dart';
import '../data/inspirational_ayahs.dart';
import '../theme.dart';

/// Cycles through short ayahs with a gentle fade transition.
class RotatingAyahFooter extends StatefulWidget {
  final double arabicSize;
  final double englishSize;
  final Duration interval;

  const RotatingAyahFooter({
    super.key,
    this.arabicSize = 16,
    this.englishSize = 11,
    this.interval = const Duration(seconds: 45),
  });

  @override
  State<RotatingAyahFooter> createState() => _RotatingAyahFooterState();
}

class _RotatingAyahFooterState extends State<RotatingAyahFooter> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % inspirationalAyahs.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ayah = inspirationalAyahs[_index];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Column(
        key: ValueKey(_index),
        children: [
          Text(
            ayah.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppText.arabic(size: widget.arabicSize, color: AppColors.goldLight),
          ),
          const SizedBox(height: 6),
          Text(
            ayah.english,
            textAlign: TextAlign.center,
            style: AppText.sans(
              size: widget.englishSize,
              color: AppColors.textMuted,
              italic: true,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ayah.reference,
            style: AppText.label(
              size: 9,
              color: AppColors.textMuted,
              spacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
