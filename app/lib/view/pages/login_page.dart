import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zero/core/dio/dio_client.dart';
import 'package:zero/main.dart';
import 'package:zero/extension/string_extension.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final Dio dio = DioClient.zeroClient;
  final error = "".obs;

  _LoginPageState();

  final box = Hive.box("setting");
  String? server;
  String? username;
  String? password;

  @override
  void initState() {
    super.initState();
    server = box.get("server");
    username = box.get("username");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text("登录"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 300),
          TextField(
            controller: TextEditingController(text: server),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Zero URL",
            ),
            onChanged: (t) => server = t,
          ),
          SizedBox(height: 20),
          TextField(
            controller: TextEditingController(
              text: username ?? box.get("username"),
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "用户名",
            ),
            onChanged: (t) => username = t,
          ),
          SizedBox(height: 20),
          TextField(
            controller: TextEditingController(text: password),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "密码",
            ),
            onChanged: (t) => password = t,
          ),
          SizedBox(height: 5),
          Obx(
            () =>
                error.value == ""
                    ? SizedBox()
                    : Text(
                      error.value,
                      style: TextStyle(color: Colors.redAccent),
                    ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            if (server.empty || username.empty || password.empty) {
              error.value = "所有字段都不能为空";
              return;
            }
            Get.dialog(
              Center(child: CircularProgressIndicator()),
              barrierDismissible: false,
            );
            try {
              var resp = await dio.get(server!);
              Get.back();
              final serverVersion = resp.data["data"]["version"];
              final localVersion = (await PackageInfo.fromPlatform()).version;
              if (serverVersion != localVersion) {
                error.value = "客户端版本($localVersion)与服务器版本($serverVersion)不匹配";
                return;
              }
              box.put("server", server);
              box.put("username", username);
              error.value = "";
              resp = await dio.post(
                "$server/user/login",
                queryParameters: {"username": username, "password": password},
              );
              if (resp.data["code"] == 200) {
                final token = resp.data["data"]["access_token"];
                Hive.box("setting").put("access_token", token);
                dio.options.baseUrl = server!;
                Get.back();
                isLogin.value = true;
                Get.offAll(() => App());
                return;
              }
              error.value = "用户名或密码错误";
            } catch (e) {
              Get.back();
              error.value = e.toString();
            }
          },
          child: Text("确认"),
        ),
      ],
    );
  }
}
