import 'package:zero/model/anime.dart';
import 'package:zero/model/resource.dart';

class ZeroMapper {
  static Anime toAnime(Map<String, dynamic> json) {
    return Anime(id: json['id'], title: json['title'], image: json['image']);
  }

  static AnimeResource toAnimeResource(Map<String, dynamic> json) {
    return AnimeResource(
      title: json['title'],
      url: json['url'],
      size: (json['size'] / 1024.0 / 1024 as double).toStringAsFixed(2),
    );
  }

  static AnimeTask toAnimeTask(Map<String, dynamic> json) {
    return AnimeTask(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      completed: json['completed'],
      size: json['size'],
      speed: json['speed'],
      name: json['name'],
    );
  }
}
