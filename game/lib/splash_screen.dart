import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Full-screen splash video (skippable on tap).
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/game_d_intro.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      })
      ..addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    if (_done) return;
    final pos = _controller.value.position;
    final dur = _controller.value.duration;
    if (dur.inMilliseconds > 0 && pos >= dur) {
      _finish();
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _controller.pause();
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _finish,
      child: Container(
        color: Colors.black,
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
