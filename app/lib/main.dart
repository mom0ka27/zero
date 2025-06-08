import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zero/binding/app_binding.dart';
import 'package:zero/controller/anime_controller.dart';
import 'package:zero/core/dio/dio_client.dart';
import 'package:zero/view/pages/library_page.dart';
import 'package:zero/view/pages/login_page.dart';
import 'package:zero/view/pages/search_page.dart';
import 'package:zero/view/pages/task_page.dart';

late Directory appDocDir;

final isLogin = true.obs;
String accessToken = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appDocDir = await getApplicationDocumentsDirectory();

  MediaKit.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("history");
  await Hive.openBox("setting");

  accessToken = Hive.box("setting").get("access_token") ?? "";

  runApp(
    GetMaterialApp(
      title: 'Zero',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 133, 201, 220),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 133, 201, 220),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      home: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _selectedIndex = 0;
  final controller = PageController(keepPage: true);
  AnimeController animeController = Get.find();

  @override
  void initState() {
    super.initState();
    Future(() async {
      if ((await DioClient.zeroClient.get("/user/info")).statusCode == 200) {
        isLogin.value = true;
      } else {
        isLogin.value = false;
      }
    });
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 5));
      if (_selectedIndex != 2) {
        return true;
      }
      try {
        animeController.fetchTaskList();
      } catch (e) {}
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          !isLogin.value
              ? LoginPage()
              : Scaffold(
                extendBodyBehindAppBar: true,
                resizeToAvoidBottomInset: false,
                body: Row(
                  children: [
                    NavigationRail(
                      labelType: NavigationRailLabelType.all,
                      elevation: 2,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_rounded),
                          label: Text("资料库"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search_rounded),
                          label: Text("搜索"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.download_rounded),
                          label: Text("任务"),
                        ),
                      ],
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                          controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.fastOutSlowIn,
                          );
                        });
                      },
                    ),
                    Expanded(
                      child: PageView(
                        controller: controller,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        children: [LibraryPage(), SearchPage(), TaskPage()],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
