import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zero/player/extension/duration.dart';
import 'widget/top_bar.dart';
import 'controller.dart';
import 'widget/bottom_bar.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ns_danmaku/ns_danmaku.dart';

class IndexPlayer extends StatefulWidget {
  final IndexPlayerController controller;

  const IndexPlayer(this.controller, {super.key});

  @override
  State<IndexPlayer> createState() => _IndexPlayerState();

  static void init() {
    MediaKit.ensureInitialized();
  }
}

class _IndexPlayerState extends State<IndexPlayer> {
  Rx<bool> showControls = false.obs;
  Rx<bool> superSpeed = false.obs;

  Timer? _autoHideControls;

  @override
  void initState() {
    super.initState();
    // 自动隐藏控制栏
    showControls.listen((v) {
      if (v) {
        _autoHideControls = Timer(Duration(seconds: 5), () {
          showControls.value = false;
        });
      } else {
        _autoHideControls?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height:
            widget.controller.isFullScreen.value
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.width / 16 * 9,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Video(
              key: widget.controller.videoKey,
              controller: widget.controller.videoController,
              controls: null,
              subtitleViewConfiguration: SubtitleViewConfiguration(
                style: TextStyle(
                  color: Colors.white,
                  // fontFamily: "FangZhengZhunYuanJianTi",
                  // borderColor: Colors.pink[200],
                  fontSize: 32,
                ),
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                // letterSpacing: 0.0,
                // wordSpacing: 0.0,
              ),
            ),
            Opacity(
              opacity: widget.controller.enableDanmaku.value ? 1 : 0,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: DanmakuView(
                  createdController: (c) {
                    widget.controller.setDanmakuController(c);
                  },
                  option: DanmakuOption(strokeWidth: 1, duration: 6),
                ),
              ),
            ),
            GestureDetector(
              // 显示控制栏
              onTap: () {
                showControls.value = !showControls.value;
              },
              // 暂停/继续
              onDoubleTap: () {
                if (widget.controller.state.playing) {
                  widget.controller.pause();
                } else {
                  widget.controller.play();
                }
              },
              // 倍速
              onLongPressStart: (ignore) {
                superSpeed.value = true;
                widget.controller.setSpeed(2);
                HapticFeedback.mediumImpact();
              },
              onLongPressUp: () {
                superSpeed.value = false;
                widget.controller.setSpeed(1);
              },
              // 快进
              onHorizontalDragStart: (ignore) {
                widget.controller.wantSeeking.value = true;
              },
              onHorizontalDragUpdate: (details) {
                final int curSliderPosition =
                    widget.controller.sliderPostion.value.inMilliseconds;
                final double scale = 90000 / MediaQuery.sizeOf(context).width;
                final Duration pos = Duration(
                  milliseconds:
                      curSliderPosition + (details.delta.dx * scale).round(),
                );

                widget.controller.sliderPostion.value = pos.clamp(
                  Duration.zero,
                  widget.controller.state.duration,
                );
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                widget.controller.seek(widget.controller.sliderPostion.value);
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(
                () => Padding(
                  padding:
                      widget.controller.isFullScreen.value
                          ? EdgeInsets.symmetric(horizontal: 40)
                          : EdgeInsets.zero,
                  child: AnimatedOpacity(
                    opacity: showControls.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: IgnorePointer(
                      ignoring: showControls.isFalse,
                      child: BottomBar(controller: widget.controller),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Obx(
                () => Padding(
                  padding:
                      widget.controller.isFullScreen.value
                          ? EdgeInsets.symmetric(horizontal: 40)
                          : EdgeInsets.zero,
                  child: AnimatedOpacity(
                    opacity: showControls.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: IgnorePointer(
                      ignoring: showControls.isFalse,
                      child: TopBar(controller: widget.controller),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(0, -0.8),
              child: Obx(
                () => AnimatedOpacity(
                  opacity: superSpeed.value ? 1 : 0,
                  duration: const Duration(milliseconds: 75),
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            "倍速中",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(0, -0.8),
              child: Obx(
                () => AnimatedOpacity(
                  opacity: widget.controller.wantSeeking.value ? 1 : 0,
                  duration: const Duration(milliseconds: 75),
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Text(
                            "${widget.controller.state.position.str} -> ${widget.controller.sliderPostion.value.str}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
