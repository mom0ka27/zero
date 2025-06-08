import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImg extends StatelessWidget {
  final String uri;
  final double? height;
  final double? width;

  const NetworkImg(this.uri, {super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    var devicePixelRatio = MediaQuery.of(context).devicePixelRatio * 1.6;

    return LayoutBuilder(
      builder: (context, constraints) {
        int? memCacheHeight =
            constraints.maxHeight != double.infinity
                ? (constraints.maxHeight * devicePixelRatio).round()
                : null;
        // int? memCacheWidth =
        //     constraints.maxWidth != double.infinity
        //         ? (constraints.maxWidth * devicePixelRatio).round()
        //         : null;
        final _height =
            height ??
            (constraints.maxHeight != double.infinity
                ? constraints.maxHeight
                : null);
        final _width =
            width ??
            (constraints.maxWidth != double.infinity
                ? constraints.maxWidth
                : null);

        return ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: uri,
            height: _height,
            width: _width,
            fit: BoxFit.cover,
            memCacheHeight: memCacheHeight,
            errorWidget:
                (c, s, o) => Center(
                  child: Text("图片消失了", style: TextStyle(fontSize: 24)),
                ),
          ),
        );
      },
    );
  }
}
