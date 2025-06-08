import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/controller/resource_controller.dart';
import 'package:zero/model/anime.dart';

class ResourcePage extends StatelessWidget {
  final AnimeDetailed anime;

  ResourcePage({super.key, required this.anime});
  final ResourceController resourceController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("下载")),
      body: Obx(
        () =>
            resourceController.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: resourceController.resourceList.length,
                  itemBuilder: (c, i) {
                    final r = resourceController.resourceList[i];
                    return Card(
                      child: ListTile(
                        title: Text(r.title),
                        subtitle: Text("${r.size} GiB"),
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: Text("新建任务"),
                              content: ListTile(
                                title: Text(r.title),
                                subtitle: Text("${r.size} GiB"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text("取消"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Get.back();
                                    Get.dialog(
                                      Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      barrierDismissible: false,
                                    );
                                    await resourceController.addTask(anime, r);
                                    Get.back();
                                    Get.dialog(
                                      AlertDialog(
                                        title: Text("成功"),
                                        content: Text("已成功添加任务"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: Text("关闭"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text("确认"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
