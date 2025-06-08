import 'package:dio/dio.dart';
import 'package:zero/data/bgm/bgm_mapper.dart';
import 'package:zero/model/anime.dart';

class BgmService {
  final Dio dio;

  BgmService(this.dio);

  Future<List<AnimeDetailed>> searchAnime(String keyword) async {
    final resp = await dio.post(
      "/v0/search/subjects",
      data: {
        "keyword": keyword,
        "sort": "rank",
        "filter": {
          "type": [2],
        },
      },
    );
    final list =
        (resp.data["data"] as List)
            .map((e) => BgmMapper.toAnimeDetailed(e))
            .toList();
    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  Future<List> getEpisodeList(int id) async {
    final resp = await dio.get(
      "/v0/episodes",
      queryParameters: {"subject_id": id.toString()},
    );
    return resp.data["data"];
  }
}
