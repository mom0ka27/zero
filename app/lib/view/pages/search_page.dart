import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/controller/anime_controller.dart';
import 'package:zero/controller/resource_controller.dart';
import 'package:zero/extension/string_extension.dart';
import 'package:zero/extension/theme_extension.dart';
import 'package:zero/model/anime.dart';
import 'package:zero/view/pages/resource_page.dart';
import 'package:zero/view/widget/anime_grid.dart';
import 'package:zero/view/widget/image.dart';
import 'package:zero/view/widget/rating_card.dart';
import 'package:zero/view/widget/tags_wrap.dart';

const blurHeight = 400.0;
const width = 600.0;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final AnimeController animeController = Get.find();
  RxBool showDetail = false.obs;

  Map<int, ColorScheme> colorSchemeCache = {};
  Rx<Widget> widgetCache = Rx(SizedBox());

  @override
  void initState() {
    super.initState();
    animeController.searchResults.stream.listen((list) {
      colorSchemeCache.clear();
      for (var a in list) {
        Future(() async {
          if (a.image.empty) {
            return;
          }
          colorSchemeCache[a.id] = await ColorScheme.fromImageProvider(
            brightness: Theme.brightnessOf(context),
            provider: CachedNetworkImageProvider(a.image),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 40),
              SearchBar(
                onSubmitted: (text) {
                  if (text.replaceAll(" ", "") == "") {
                    animeController.searchResults.value = [];
                    return;
                  }
                  animeController.searchAnime(text);
                },
              ),
              SizedBox(height: 20),

              Expanded(
                child: Obx(
                  () =>
                      animeController.searchLoading.value
                          ? Center(child: CircularProgressIndicator())
                          : animeController.searchResults.isEmpty
                          ? Center(
                            child: Text(
                              "这里什么都没有呢",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                          : AnimeGrid(
                            animeList: animeController.searchResults,
                            onTap: (i) {
                              FocusScope.of(context).unfocus();
                              final a = animeController.searchResults[i];
                              if (!colorSchemeCache.containsKey(a.id)) {
                                return;
                              }
                              widgetCache.value = DetailPanel(
                                a,
                                colorScheme: colorSchemeCache[a.id]!,
                              );
                              showDetail.value = true;
                            },
                          ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Obx(
              () => RepaintBoundary(
                child: AnimatedOpacity(
                  duration:
                      showDetail.value
                          ? Duration(milliseconds: 400)
                          : Duration(milliseconds: 200),
                  opacity: showDetail.value ? 1.0 : 0.0,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: IgnorePointer(
                      ignoring: !showDetail.value,
                      child: GestureDetector(
                        child: Container(
                          color: Colors.transparent, // 让背景透明，以显示模糊
                        ),
                        onTap: () => showDetail.value = false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => AnimatedPositioned(
              duration:
                  showDetail.value
                      ? Duration(milliseconds: 400)
                      : Duration(milliseconds: 200),
              top: 0,
              bottom: 0,
              right: showDetail.value ? 0 : -width,
              width: width,
              curve: Curves.fastOutSlowIn,
              onEnd: () {
                if (!showDetail.value) {
                  widgetCache.value = SizedBox();
                }
              },
              child: widgetCache.value,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DetailPanel extends StatelessWidget {
  final AnimeDetailed anime;
  final ColorScheme colorScheme;

  const DetailPanel(this.anime, {super.key, required this.colorScheme});
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      child: Builder(
        builder:
            (context) => Container(
              width: width,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  NetworkImg(anime.image, height: blurHeight, width: width),
                  ClipRect(
                    child: SizedBox(
                      height: blurHeight,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          color: Colors.transparent,
                          height: blurHeight,
                          width: width,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    height: blurHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).canvasColor,
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60, left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                child: NetworkImg(
                                  anime.image,
                                  height: 300,
                                  width: 210,
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: width - 250,
                                height: 300,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),

                                        Text(
                                          anime.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white54,
                                                  width: 1.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                anime.date,
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.onImage,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 14),
                                            Text(
                                              "全 ${anime.eps} 话",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onImage,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 30),
                                        RatingCard(
                                          rating: anime.rating,
                                          rank: anime.rank,
                                          count: anime.count,
                                        ),
                                      ],
                                    ),

                                    FilledButton.icon(
                                      onPressed: () async {
                                        AnimeController animeController =
                                            Get.find();
                                        if (animeController.remoteAnimeList.any(
                                          (a) => a.id == anime.id,
                                        )) {
                                          Get.dialog(
                                            AlertDialog(
                                              title: Text("出错了"),
                                              content: Text(
                                                "你已经下过这部番了哦\n目前版本不支持为一部番剧添加多个数据源",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: Text("关闭"),
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }
                                        String? keyword = await showDialog(
                                          context: context,
                                          builder: (c) {
                                            String text = anime.title;
                                            return AlertDialog(
                                              title: Text("搜索关键词"),
                                              content: TextField(
                                                controller:
                                                    TextEditingController(
                                                      text: anime.title,
                                                    ),
                                                onChanged: (t) => text = t,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("取消"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      text,
                                                    );
                                                  },
                                                  child: Text("确认"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (keyword == null) {
                                          return;
                                        }
                                        ResourceController c = Get.find();
                                        c.fetchResource(keyword);
                                        Get.to(
                                          () => ResourcePage(anime: anime),
                                        );
                                      },
                                      label: Text(
                                        "下载",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      icon: Icon(Icons.download),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              anime.summary,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(height: 10),
                          TagsWrap(anime.tags),
                          SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
