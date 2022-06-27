import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
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
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        decodeResult = null;
        upload(pickedFile.path);
      }
    });
  }

  Future upload(String filePath) async {
    Uri uri = Uri.parse("http://localhost:8081/predict");

    http.MultipartRequest request = new http.MultipartRequest("POST", uri);

    http.MultipartFile multipartFile =
        await http.MultipartFile.fromPath('file', filePath);

    request.files.add(multipartFile);

    var response = await request.send();
    var responseString = await response.stream.bytesToString();

    // jsondecode
    decodeResult = json.decode(responseString);

    setState(() {});
    // print(decodeResult[0]['labels']);
  }

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(15),
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
