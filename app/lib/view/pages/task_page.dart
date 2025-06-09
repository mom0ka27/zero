import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/controller/anime_controller.dart';
import 'package:zero/extension/size_extension.dart';
import 'package:zero/view/widget/image.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key});

  final AnimeController animeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            animeController.taskList.isEmpty
                ? Center(
                  child: Text(
                    "这里什么都没有呢",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
                : ListView.builder(
                  itemCount: animeController.taskList.length,
                  itemBuilder: (c, i) {
                    final task = animeController.taskList[i];
                    return Card(
                      child: SizedBox(
                        height: 300,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NetworkImg(task.image, height: 300),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 26,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      task.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          task.size != 0
                                              ? "${(task.completed / task.size * 100).toStringAsFixed(2)} %"
                                              : "正在加载元数据",
                                        ),

                                        Spacer(),
                                        Text(
                                          "${task.completed.toGiB} / ${task.size.toGiB} GiB",
                                        ),
                                        SizedBox(width: 20),

                                        Text("${task.speed.toMiB} MiB/s"),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    LinearProgressIndicator(
                                      value:
                                          task.size == 0
                                              ? null
                                              : task.completed / task.size,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
