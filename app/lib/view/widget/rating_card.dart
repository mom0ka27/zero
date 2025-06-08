import 'package:flutter/material.dart';
import 'package:zero/extension/theme_extension.dart';

class RatingCard extends StatelessWidget {
  final double rating;
  final int rank;
  final int count;

  const RatingCard({
    super.key,
    required this.rating,
    required this.rank,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    // 转换成 5 星制评分
    double starRating = (rating / 2).clamp(0.0, 5.0);
    int fullStars = starRating.floor();
    bool hasHalfStar = (starRating - fullStars) >= 0.5;

    final color = Theme.of(context).colorScheme.onImage;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Row(
              children: List.generate(5, (index) {
                if (index < fullStars) {
                  return Icon(Icons.star_rounded, size: 22, color: color);
                } else if (index == fullStars && hasHalfStar) {
                  return Icon(Icons.star_half_rounded, size: 22, color: color);
                } else {
                  return Icon(
                    Icons.star_border_rounded,
                    size: 22,
                    color: color,
                  );
                }
              }),
            ),
            Text(
              '$count 人评 | #$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
