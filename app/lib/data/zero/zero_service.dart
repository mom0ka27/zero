import 'package:dio/dio.dart';
import 'package:zero/data/zero/zero_mapper.dart';
import 'package:zero/model/anime.dart';
import 'package:zero/model/resource.dart';

class ZeroService {
  final Dio dio;

  ZeroService(this.dio);

  Future<List<Anime>> fetchRemoteAnimeList() async {
    final resp = await dio.get("/storage/list");

    return await Future.wait(
      (resp.data["data"] as List).map((ra) async {
        final a = ZeroMapper.toAnime(ra);
        return a;
      }),
    );
  }

  Future<List<AnimeResource>> fetchResource(String keyword) async {
    final resp = await dio.get("/source/search?keyword=$keyword");
    return (resp.data["data"] as List)
        .map((r) => ZeroMapper.toAnimeResource(r))
        .toList();
  }

  Future<void> addTask(int id, String title, String image, String url) async {
    await dio.post(
      "/storage/download",
      queryParameters: {
        "id": id.toString(),
        "title": title,
        "image": image,
        "magnet": url,
      },
    );
  }

  Future<List<AnimeTask>> fetchTaskList() async {
    final resp = await dio.get("/storage/task");
    return (resp.data["data"] as List)
        .map((t) => ZeroMapper.toAnimeTask(t))
        .toList();
  }
}
