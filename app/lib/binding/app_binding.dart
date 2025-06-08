import 'package:get/get.dart';
import 'package:zero/controller/anime_controller.dart';
import 'package:zero/controller/resource_controller.dart';
import 'package:zero/core/dio/dio_client.dart';
import 'package:zero/data/bgm/bgm_service.dart';
import 'package:zero/data/zero/zero_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DioClient.zeroClient, tag: "zero");
    Get.lazyPut(() => DioClient.bgmClient, tag: "bgm");

    Get.lazyPut(() => ZeroService(Get.find(tag: "zero")));
    Get.lazyPut(() => BgmService(Get.find(tag: "bgm")));

    Get.lazyPut(
      () => AnimeController(bgmService: Get.find(), zeroService: Get.find()),
    );
    Get.lazyPut(() => ResourceController(zeroService: Get.find()));
  }
}
