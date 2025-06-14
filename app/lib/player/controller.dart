import 'dart:async';

import 'package:auto_orientation_v2/auto_orientation_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'model/danmaku.dart';
import 'model/option.dart';

import 'model/video.dart' as models;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ns_danmaku/ns_danmaku.dart';

class IndexPlayerController {
  final _player = Player(
    configuration: PlayerConfiguration(libass: true),
  ); //configuration: PlayerConfiguration(vo: "gpu")
  late final VideoController _controller = VideoController(
    _player,
    configuration: const VideoControllerConfiguration(
      // hwdec: "mediacodec",
      // vo: "gpu",
    ),
  );

  final IndexPlayerOptions options;

  final GlobalKey<VideoState> _videoKey = GlobalKey();

  DanmakuController? _danmakuController;
  final Rx<bool> enableDanmaku = true.obs;
  DanmakuList? _danmakuList;

  VideoController get videoController => _controller;

  PlayerState get state => _player.state;

  bool _seeking = false;

  /// 是否在加载快进
  bool get seeking => _seeking;

  /// 显示快进条
  final Rx<bool> wantSeeking = false.obs;

  /// 进度条位置
  final Rx<Duration> sliderPostion = Rx(Duration.zero);

  final Rx<bool> isFullScreen = false.obs;

  final Rx<models.Video?> _video = Rx(null);

  Rx<models.Video?> get video => _video;

  GlobalKey<VideoState> get videoKey => _videoKey;

  bool _disposed = false;

  IndexPlayerController({this.options = const IndexPlayerOptions()}) {
    // (_player.platform as NativePlayer)
    //     .getProperty("gpu-api")
    //     .then((v) => print("gpu-api: $v"));

    Future.doWhile(() async {
      if (_disposed) return false;
      await Future.delayed(Duration(milliseconds: 500));
      if (seeking) {
        return true;
      }
      if (wantSeeking.isFalse) {
        sliderPostion.value = state.position;
      }
      return true;
    });

    Future.doWhile(() async {
      if (_disposed) return false;
      // 弹幕
      try {
        await stream.position.first; // 弹幕和视频同步
      } catch (_) {}
      _danmakuController?.addItems(
        _danmakuList?.getDanmakus(state.position.inSeconds) ?? [],
      );
      await Future.delayed(Duration(seconds: 1));
      return true;
    });
  }

  /// 设置播放的视频
  ///
  /// 视频加载后立即返回，不会等待弹幕加载
  Future<void> setVideo(models.Video video, {Duration? start}) async {
    this.video.value = video;
    await _player.open(
      Media(
        video.uri.toString(),
        httpHeaders: video is models.NetworkVideo ? video.httpHeaders : null,
        start: start,
      ),
    );
    try {
      await _player.stream.duration.first; // 等待视频加载
    } catch (_) {
      return;
    }
    if (video.subtitleUri != null) {
      await _player.setSubtitleTrack(SubtitleTrack.uri(video.subtitleUri!));
    }
    _danmakuController?.clear();
    video.danmakuProvider?.getDanmakuList().then((l) => _danmakuList = l);
  }

  void setDanmakuController(DanmakuController controller) {
    _danmakuController = controller;
  }

  Future<void> pause() async {
    await _player.pause();
    _danmakuController?.pause();
  }

  Future<void> play() async {
    await _player.play();
    _danmakuController?.resume();
  }

  Future<void> seek(Duration d) async {
    wantSeeking.value = false;

    _seeking = true;
    sliderPostion.value = d;

    _player.pause();
    _danmakuController?.pause();

    await _player.seek(d);

    _danmakuController?.clear();
    await _player.play();
    _danmakuController?.resume();
    _seeking = false;
  }

  Future<void> enterFullscreen() async {
    await AutoOrientation.landscapeAutoMode();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    isFullScreen.value = true;
  }

  Future<void> exitFullscreen() async {
    await AutoOrientation.portraitAutoMode();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    isFullScreen.value = false;
  }

  Future<void> setSpeed(double rate) async {
    _danmakuController?.updateOption(
      _danmakuController!.option.copyWith(
        duration:
            _danmakuController!.option.duration * _player.state.rate / rate,
      ),
    );
    await _player.setRate(rate);
  }

  Future<void> dispose() async {
    _disposed = true;
    await _player.dispose();
    _danmakuController?.clear();
  }

  PlayerStream get stream => _player.stream;
}
