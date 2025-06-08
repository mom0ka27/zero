import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller.dart';

class TopBar extends StatefulWidget {
  final IndexPlayerController controller;

  const TopBar({super.key, required this.controller});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () async {
            // await widget.controller.exitFullscreen();
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        SizedBox(width: 10),
        Obx(
          () => Text(
            widget.controller.video.value?.title ?? "",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Spacer(),
      ],
    );
  }
}
