import 'package:zero/model/anime.dart';
import 'package:zero/model/episode.dart';

class BgmMapper {
  static AnimeDetailed toAnimeDetailed(Map<String, dynamic> json) {
    return AnimeDetailed(
      id: json['id'],
      title: json['name_cn'] != '' ? json['name_cn'] : json['name'],
      image: json['images']['medium'],
      summary: json['summary'],
      tags: (json['tags'] as List).map((e) => e['name'] as String).toList(),
      rank: json['rating']['rank'],
      rating: json['rating']['score'].toDouble(),
      count: json['rating']['total'],
      eps: json['eps'],
      date: json['date'] ?? "???",
    );
  }

  static Episode toEpisode(Map<String, dynamic> json) {
    return Episode(
      title: json['name_cn'] != '' ? json['name_cn'] : json['name'],
      desc: json['desc'],
      index: json['ep'],
    );
  }
}
