import 'package:get/get.dart';
import 'package:zero/data/bgm/bgm_service.dart';
import 'package:zero/data/zero/zero_service.dart';
import 'package:zero/model/anime.dart';

class AnimeController extends GetxController {
  final BgmService bgmService;
  final ZeroService zeroService;

  AnimeController({required this.bgmService, required this.zeroService});

  final remoteAnimeList = <RemoteAnime>[].obs;
  final listLoading = false.obs;

  final searchResults = <AnimeDetailed>[].obs;
  final searchLoading = false.obs;

  final taskList = <AnimeTask>[].obs;

  Future<void> fetchRemoteAnimeList() async {
    listLoading.value = true;
    remoteAnimeList.value = await zeroService.fetchRemoteAnimeList();
    listLoading.value = false;
  }

  Future<void> searchAnime(String keyword) async {
    searchLoading.value = true;
    searchResults.value = await bgmService.searchAnime(keyword);
    searchLoading.value = false;
  }

  Future<void> fetchTaskList() async {
    taskList.value = await zeroService.fetchTaskList();
  }
}
