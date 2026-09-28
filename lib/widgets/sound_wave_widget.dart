import 'package:flutter/material.dart';
import 'dart:math' as math;

class SoundWaveWidget extends StatefulWidget{
  final bool isSpeaking;
  const SoundWaveWidget({super.key, required this.isSpeaking});

  @override
  State<SoundWaveWidget> createState() => _SoundWaveWidgetState();
}

class _SoundWaveWidgetState extends State<SoundWaveWidget> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(widget.isSpeaking ? 0.35 : 0.1),
                  blurRadius: 25,
                  spreadRadius: 4,
                ),
              ]
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF12121A),
                    border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      widget.isSpeaking ? Icons.volume_up_rounded : Icons.mic_rounded,
                      size: 40,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (index) {
                    double multiplier = widget.isSpeaking ? 1.0 : 0.25;
                    double waveHeight = 15 + (35 * math.sin((_controller.value * math.pi) + (index * 0.7)).abs() * multiplier);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 6,
                      height: waveHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                )
              ],
            ),
          );
        }
    );
  }
}