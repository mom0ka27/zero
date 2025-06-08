import 'package:flutter/material.dart';
import 'package:zero/view/widget/image.dart';

class OverlayTextCard extends StatelessWidget {
  final String url;
  final String text;
  final GestureTapCallback? onTap;

  const OverlayTextCard({
    super.key,
    required this.url,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // 卡片圆角
        child: Stack(
          children: [
            NetworkImg(url),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: [0.5, 1.0], // 50%处开始加深
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,

              child: SizedBox(
                width: 200,
                child: Text(
                  text,
                  maxLines: 3,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
