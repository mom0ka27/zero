import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero/main.dart';
import 'package:zero/view/pages/login_page.dart';

class DioClient {
  // ignore: prefer_function_declarations_over_variables
  static final errorHandler = (DioException e, handler) {
    if (e.response?.statusCode == 401) {
      if (!isLogin.value) {
        Get.offAll(() => LoginPage());
        return;
      }
      Get.dialog(
        AlertDialog(
          title: Text('出错了'),
          content: Text('登陆状态丢失, 请重新登陆.'),
          actions: [
            TextButton(
              child: Text('确认'),
              onPressed: () {
                Get.back();
                Get.offAll(() => LoginPage());
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return;
    }
    if (e.response?.statusCode == 403) {
      if (!isLogin.value) {
        Get.offAll(() => LoginPage());
        return;
      }
      Get.dialog(
        AlertDialog(
          title: Text('出错了'),
          content: Text('你没有权限这么做.'),
          actions: [
            TextButton(
              child: Text('确认'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return;
    }
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    print(e.stackTrace);
    Get.dialog(
      AlertDialog(
        title: Text('网络错误'),
        content: Text(e.message ?? '未知错误, 请检查网络'),
        actions: [TextButton(child: Text('关闭'), onPressed: () => Get.back())],
      ),
    );
  };

  static final Dio _zero = Dio(
      BaseOptions(
        baseUrl: Hive.box("setting").get("server") ?? "",
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 20),
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $accessToken';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 拦截业务 code != 200
          if (response.data is Map && response.data['code'] != 200) {
            final msg =
                response.data['message'] ?? '[${response.data['code']}]未知错误';
            if (Get.isDialogOpen == true) {
              Get.back();
            }
            Get.dialog(
              AlertDialog(
                title: Text('出错了'),
                content: Text(msg),
                actions: [
                  TextButton(child: Text('关闭'), onPressed: () => Get.back()),
                ],
              ),
            );
            return;
          }
          handler.next(response); // 正常传递响应
        },
        onError: errorHandler,
      ),
    );

  static final Dio _bangumi = Dio(
    BaseOptions(
      baseUrl: 'https://api.bgm.tv',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  )..interceptors.add(InterceptorsWrapper(onError: errorHandler));

  static Dio get zeroClient => _zero;
  static Dio get bgmClient => _bangumi;
}
