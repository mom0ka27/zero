class Anime {
  final int id;
  final String title;
  final String image;

  const Anime({required this.id, required this.title, required this.image});
}

class AnimeDetailed extends Anime {
  final String summary;
  final List<String> tags;

  final int rank;
  final double rating;
  final int count;

  final int eps;
  final String date;

  const AnimeDetailed({
    required super.id,
    required super.title,
    required super.image,
    required this.summary,
    required this.tags,
    required this.rank,
    required this.rating,
    required this.count,
    required this.eps,
    required this.date,
  });
}

class AnimeTask extends Anime {
  final int completed;
  final int size;
  final int speed;
  final String name;

  const AnimeTask({
    required super.id,
    required super.title,
    required super.image,
    required this.completed,
    required this.size,
    required this.speed,
    required this.name,
  });
}
