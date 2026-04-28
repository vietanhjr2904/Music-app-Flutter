// ignore: file_names
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_clone/controllers/main_controller.dart';

class PlayingControls extends StatefulWidget {
  final bool isPlaying;
  final LoopMode? loopMode;
  final bool isPlaylist;
  final MainController con;
  final Function()? onPrevious;
  final Function() onPlay;
  final Function()? onNext;
  final Function()? toggleLoop;
  final Function()? onStop;

  const PlayingControls({
    Key? key,
    required this.isPlaying,
    this.loopMode,
    this.isPlaylist = false,
    required this.con,
    this.onPrevious,
    required this.onPlay,
    this.onNext,
    this.toggleLoop,
    this.onStop,
  }) : super(key: key);

  @override
  State<PlayingControls> createState() => _PlayingControlsState();
}

class _PlayingControlsState extends State<PlayingControls> {
  bool isSuffled = false;
  static const List<double> _speeds = [1.0, 1.5, 2.0, 3.0];
  int _speedIndex = 0;

  @override
  void initState() {
    setState(() {
      isSuffled = widget.con.player.shuffle;
    });
    super.initState();
  }

  Icon loopIcon(BuildContext context) {
    if (widget.loopMode == LoopMode.none) {
      return const Icon(
        CupertinoIcons.arrow_2_circlepath,
        color: Colors.grey,
        size: 24,
      );
    } else if (widget.loopMode == LoopMode.playlist) {
      return const Icon(
        CupertinoIcons.arrow_2_circlepath,
        size: 24,
        color: Colors.white,
      );
    } else {
      return const Icon(
        CupertinoIcons.arrow_2_circlepath,
        size: 24,
        color: Colors.green,
      );
    }
  }

  Future<void> _seekRelative(Duration delta) async {
    final pos = widget.con.player.currentPosition.value;
    final dur =
        widget.con.player.current.value?.audio.duration ?? const Duration();
    var target = pos + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (dur > Duration.zero && target > dur) target = dur;
    await widget.con.player.seek(target);
  }

  Future<void> _cycleSpeed() async {
    setState(() {
      _speedIndex = (_speedIndex + 1) % _speeds.length;
    });
    await widget.con.player.setPlaySpeed(_speeds[_speedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: const EdgeInsets.all(0),
                splashRadius: 24,
                onPressed: () {
                  setState(() {
                    isSuffled = !isSuffled;
                  });
                  widget.con.player.toggleShuffle();
                },
                icon: isSuffled
                    ? const Icon(LineIcons.random, color: Colors.green)
                    : const Icon(LineIcons.random, color: Colors.white),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: widget.isPlaylist ? widget.onPrevious : null,
                    icon: const Icon(
                      Icons.skip_previous,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    width: 120,
                    child: IconButton(
                      onPressed: widget.onPlay,
                      icon: Icon(
                        widget.isPlaying
                            ? CupertinoIcons.pause_circle_fill
                            : CupertinoIcons.play_circle_fill,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.isPlaylist ? widget.onNext : null,
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: const EdgeInsets.all(0),
                splashRadius: 24,
                onPressed: () {
                  if (widget.toggleLoop != null) widget.toggleLoop!();
                },
                icon: loopIcon(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SeekButton(
                icon: Icons.replay_10,
                label: '-10s',
                onTap: () => _seekRelative(const Duration(seconds: -10)),
              ),
              _SeekButton(
                icon: Icons.forward_10,
                label: '+10s',
                onTap: () => _seekRelative(const Duration(seconds: 10)),
              ),
              InkWell(
                onTap: _cycleSpeed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'x${_speeds[_speedIndex] == _speeds[_speedIndex].toInt() ? _speeds[_speedIndex].toInt() : _speeds[_speedIndex]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeekButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SeekButton(
      {Key? key, required this.icon, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
