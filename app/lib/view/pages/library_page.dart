import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/controller/anime_controller.dart';
import 'package:zero/data/bgm/bgm_mapper.dart';
import 'package:zero/data/bgm/bgm_service.dart';
import 'package:zero/view/pages/player_page.dart';
import 'package:zero/view/widget/anime_grid.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin {
  final AnimeController animeController = Get.find();

  Map<int, ColorScheme> colorSchemeCache = {};

  @override
  void initState() {
    super.initState();
    animeController.remoteAnimeList.listen((list) {
      colorSchemeCache.clear();
      Future.wait(
        list.map((a) async {
          colorSchemeCache[a.id] = await ColorScheme.fromImageProvider(
            provider: CachedNetworkImageProvider(a.image),
            brightness: Theme.brightnessOf(context),
          );
        }),
      );
    });
    animeController.fetchRemoteAnimeList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Obx(
        () =>
            animeController.listLoading.value
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: () async {
                    await animeController.fetchRemoteAnimeList();
                  },
                  child: AnimeGrid(
                    animeList: animeController.remoteAnimeList,
                    onTap: (i) async {
                      final anime = animeController.remoteAnimeList[i];

                      Get.dialog(
                        Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        barrierDismissible: false,
                      );
                      final BgmService bgmService = Get.find();
                      final episodes =
                          (await bgmService.getEpisodeList(anime.id))
                              .where((ep) => ep["type"] == 0)
                              .map((ep) => BgmMapper.toEpisode(ep))
                              .toList();
                      Get.back();
                      Get.to(() {
                        return Theme(
                          data: ThemeData(
                            colorScheme:
                                colorSchemeCache[animeController
                                    .remoteAnimeList[i]
                                    .id],
                            useMaterial3: true,
                          ),
                          child: PlayerPage(anime: anime, episodes: episodes),
                        );
                      });
                    },
                  ),
                ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
