import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

//uri config etc...
import 'config/uri.dart';
import 'flutter_overboard_page.dart';

//tutorial page
// import 'flutter_overboard_page.dart';

void main() {
  runApp(const MyApp());
}

void _showTutorial(BuildContext context) async {
  final pref = await SharedPreferences.getInstance();

  if (pref.getBool('isAlreadyFirstLaunch') != true) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return FlutterOverboardPage();
        },
        fullscreenDialog: true,
      ),
    );
    pref.setBool('isAlreadyFirstLaunch', true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoAI FlutterNative',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'PhotoAI FlutterNative'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late var image = null;
  late var decodeResult = null;
  final picker = ImagePicker();

  Future getImage() async {
    // gallery
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    // camera
    // final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        decodeResult = null;
        upload(pickedFile.path);
      }
    });
  }

  Future upload(String filePath) async {
    // connect to localhost
    Uri uri = Uri.parse(endpointIos);
    if (Platform.isAndroid) {
      // Android
      uri = Uri.parse(endpointAndroid);
    }

    http.MultipartRequest request = new http.MultipartRequest("POST", uri);

    http.MultipartFile multipartFile =
        await http.MultipartFile.fromPath('file', filePath);

    request.files.add(multipartFile);

    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      // jsondecode

      decodeResult = json.decode(responseString);
      setState(() {});
    } else {
      throw Exception('Failed to connect to API');
    }

    // print(decodeResult[0]['labels']);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _showTutorial(context));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [_imageArea(image), _textArea(image, decodeResult)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _imageArea(image) {
    return Container(
      alignment: Alignment(0.0, 0.0),
      height: 200,
      width: 400,
      margin: EdgeInsets.all(40),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(width: 2, color: Colors.grey)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: image == null
            ? SvgPicture.asset(
                'assets/img/select-photo.svg',
                fit: BoxFit.fill,
                // height: 200,
                width: 400,
              )
            : Image.file(
                image,
                fit: BoxFit.fill,
                // height: 200,
                width: 400,
              ),
      ),
    );
  }

  Widget _textArea(image, result) {
    if (image == null) {
      return Text("画像を選択してください");
    } else if (result == null) {
      return Text("判別中...");
    } else {
      String percent =
          (double.parse(result[0]['results']) * 100).ceil().toString();
      return Text(percent + "%の確率で" + result[0]['labels'] + "やんけ！");
    }
  }
}
