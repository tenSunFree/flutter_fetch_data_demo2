import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_fetch_data_demo2/zoo_bean.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  runApp(MyApp());
  initializeStatusBar();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_fetch_data_demo2',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ZooBean zooBean;
  var isLoading = false;

  // 是否第一次打開此畫面
  var isFirstRun = true;

  /// 從網路取得資料
  _fetchData() async {
    setLoading(true);
    final url =
        "https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=a3e2b221-75e0-45c1-8f97-75acbd43d613&limit=20";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // 解決中文數據出現亂碼的問題
      Utf8Decoder utf8decoder = Utf8Decoder();
      var map =
          new JsonDecoder().convert(utf8decoder.convert(response.bodyBytes));
      zooBean = ZooBean.fromMap(map);
      setLoading(false);
    } else {
      throw Exception('Failed to load photos');
    }
    isFirstRun = false;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_statements
    isFirstRun ? _fetchData() : null;
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      // isLoading?[為true時執行]:[為false執行]
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    "images/icon_top_bar.png",
                    fit: BoxFit.fill,
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: CustomListView(zooBean),
                ),
                Container(
                  color: Color(0xFFF7F7F7),
                  height: 1,
                ),
                Expanded(
                  flex: 1,
                  child: Image.asset(
                    "images/icon_bottom_bar.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
    );
  }

  void setLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
    });
  }
}

// ignore: must_be_immutable
class CustomListView extends StatelessWidget {
  final ZooBean zooBean;

  CustomListView(this.zooBean);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF000000),
      child: ListView.builder(
          // 解決列表上方的空白
          padding: EdgeInsets.all(0.0),
          itemCount: zooBean.result.results.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
              child: ItemView(
                name: zooBean.result.results[index].APic03ALT,
                introduction: zooBean.result.results[index].ABehavior,
                url: zooBean.result.results[index].APic03URL,
                clickStartListener: () {
                  showToast("click index" + index.toString());
                },
                clickShareListener: () {
                  showToast("click share" + index.toString());
                },
              ),
            );
          }),
    );
  }
}

class ItemView extends StatelessWidget {
  final String introduction;
  final String name;
  final String url;
  final VoidCallback clickStartListener, clickShareListener;

  ItemView({
    this.introduction,
    this.name,
    this.url,
    this.clickStartListener,
    this.clickShareListener,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // 填滿至父布局
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
                // 填滿至父布局
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  InkWell(
                    onTap: () => clickStartListener(),
                    child: Image.network(
                      url,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ]),
            Image.asset(
              "images/icon_start.png",
              width: 27,
              height: 27,
              fit: BoxFit.contain,
            ),
            Positioned(
              top: 10.0,
              left: 10.0,
              right: 10.0,
              child: Text(
                introduction,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                  fontSize: 17,
                ),
              ),
            ),
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: Text(
                name,
                style: new TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () => clickShareListener(),
          child: Image.asset(
            "images/icon_share.png",
            height: 49,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}

/// 設置android狀態欄為透明的沉浸, 以及文字顏色變成黑色
/// 寫在組件渲染之後, 是為了在渲染後進行set賦值, 覆蓋狀態欄
/// 寫在渲染之前, MaterialApp組件會覆蓋掉這個值
void initializeStatusBar() {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent, // Color for Android
          statusBarBrightness:
              Brightness.dark // Dark == white status bar -- for IOS.
          ),
    );
  }
}

void showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIos: 1,
    backgroundColor: Color(0xCC4F4F4F),
    textColor: Color(0xFFFFFFFF),
    fontSize: 16,
  );
}
