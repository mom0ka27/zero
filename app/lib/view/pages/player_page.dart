import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:zero/main.dart';
import 'package:zero/model/anime.dart';
import 'package:zero/model/episode.dart';
import 'package:zero/player/controller.dart';
import 'package:zero/player/model/video.dart';
import 'package:zero/player/player.dart';

class PlayerPage extends StatefulWidget {
  final Anime anime;

  final List<Episode> episodes;

  const PlayerPage({super.key, required this.anime, required this.episodes});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  IndexPlayerController controller = IndexPlayerController();

  Dio dio = Get.find(tag: "zero");

  Rx<int> currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();

    Future(() async {});

    currentIndex.listen((i) async {
      final position =
          Hive.box(
            "history",
          ).get("${widget.anime.id}.${currentIndex.value}.position") ??
          0;
      await controller.setVideo(
        NetworkVideo(
          uri:
              "${dio.options.baseUrl}/storage/video?id=${widget.anime.id}&index=$currentIndex",
          subtitleUri:
              "${dio.options.baseUrl}/storage/subtitle?id=${widget.anime.id}&index=$currentIndex",
          title: widget.episodes[currentIndex.value].title,
          httpHeaders: {"Authorization": "Bearer $accessToken"},
        ),
        start: Duration(milliseconds: position),
      );
    });
    controller.stream.completed.listen((c) {
      if (c) {
        Hive.box(
          "history",
        ).put("${widget.anime.id}.${currentIndex.value}.position", 0);
        if (currentIndex.value < widget.episodes.length - 1) {
          currentIndex.value = currentIndex.value + 1;
        }
      }
    });
    controller.stream.error.listen((e) {
      if (e.contains("subtitle")) {
        return; // 忽略找不到字幕
      }
      Get.dialog(
        AlertDialog(
          title: Text("出错了"),
          content: Text(e),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("确认"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    });
    currentIndex.value =
        Hive.box("history").get("${widget.anime.id}.index") ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          Container(height: top, color: Colors.black),
          SafeArea(
            child: Obx(
              () =>
                  controller.isFullScreen.value
                      ? IndexPlayer(controller)
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IndexPlayer(controller),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.anime.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Obx(
                                  () => SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                          widget.episodes
                                              .map(
                                                (ep) => GestureDetector(
                                                  onTap: () {
                                                    Hive.box("history").put(
                                                      "${widget.anime.id}.${currentIndex.value}.position",
                                                      controller
                                                          .state
                                                          .position
                                                          .inMilliseconds,
                                                    );
                                                    currentIndex.value =
                                                        ep.index - 1;
                                                  },
                                                  child: Card(
                                                    child: Container(
                                                      width: 150,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 15,
                                                            vertical: 10,
                                                          ),
                                                      child: Text(
                                                        "第 ${ep.index} 话\n${ep.title}",
                                                        maxLines: 2,

                                                        style: TextStyle(
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          color:
                                                              ep.index - 1 ==
                                                                      currentIndex
                                                                          .value
                                                                  ? Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary
                                                                  : null,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Hive.box("history").put("${widget.anime.id}.index", currentIndex.value);
    Hive.box("history").put(
      "${widget.anime.id}.${currentIndex.value}.position",
      controller.state.position.inMilliseconds,
    );
    super.dispose();
    controller.dispose();
  }
}
