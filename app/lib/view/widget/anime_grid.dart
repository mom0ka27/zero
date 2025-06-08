import 'package:flutter/widgets.dart';
import 'package:zero/model/anime.dart';
import 'package:zero/view/widget/overlay_text.dart';

class AnimeGrid extends StatelessWidget {
  final Function(int)? onTap;

  final List<Anime> animeList;

  const AnimeGrid({super.key, this.onTap, required this.animeList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: animeList.length,
      itemBuilder: (c, i) {
        return OverlayTextCard(
          url: animeList[i].image,
          text: animeList[i].title,
          onTap: () {
            if (onTap != null) {
              onTap!(i);
            }
          },
        );
      },
    );
  }
}
