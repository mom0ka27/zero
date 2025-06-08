import 'package:get/get.dart';
import 'package:zero/data/zero/zero_service.dart';
import 'package:zero/model/anime.dart';
import 'package:zero/model/resource.dart';

class ResourceController extends GetxController {
  final ZeroService zeroService;

  ResourceController({required this.zeroService});

  final isLoading = false.obs;
  final resourceList = <AnimeResource>[].obs;

  Future<void> fetchResource(String keyword) async {
    isLoading.value = true;
    resourceList.value = await zeroService.fetchResource(keyword);
    isLoading.value = false;
  }

  Future<void> addTask(AnimeDetailed anime, AnimeResource resource) async {
    await zeroService.addTask(anime.id, anime.title, anime.image, resource.url);
  }
}
