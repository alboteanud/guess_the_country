import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Guess the country',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new MyHomePage(title: 'Guess the country'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _cachedFile;
  File _cachedFlag1, _cachedFlag2;

  Future<Null> _downloadFile() async {
    final String imgName = "${Random().nextInt(319) + 2}.jpg";
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$imgName');
    print("image: " + imgName);
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("images/" + imgName);

    // downloading
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
    final int byteNumber = (await downloadTask.future).totalByteCount;

    _downloadFlag(1);
    _downloadFlag(2);

    setState(() => _cachedFile = file);
  }

  Future<Null> _downloadFlag(int flagNo) async {
    final String imgName = flagNames[Random().nextInt(flagNames.length)];
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$imgName');
    print("flag: " + imgName);
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("country_flags/" + imgName);

    // downloading
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
    final int byteNumber = (await downloadTask.future).totalByteCount;

    if (flagNo == 1)
      _cachedFlag1 = file;
    else
      _cachedFlag2 = file;
  }

  buildLayoutBody() {
    optionRow(final String text, File flagFile) {
      return new Padding(
        padding: new EdgeInsets.only(top: 8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new RaisedButton(
              child: new Text(text),
              color: Theme.of(context).buttonColor,
              elevation: 2.0,
//            splashColor: Colors.blueGrey,
              onPressed: () {
                // Perform some action
              },
            ),
//            new SvgPicture.asset("assets/AC.svg",

            flagFile != null
                ? new SvgPicture.asset(
                    flagFile.path,
                    height: 40.0,
                    width: 80.0,
                  )
                : Container(),

//            new SvgPicture.asset(_cachedFlag.path,
//              height: 40.0,
//              width: 80.0,
//            ),
          ],
        ),
      );
    }

    return new Column(
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
//            color: Colors.lightGreen,

          child:
              _cachedFile != null ? Image.asset(_cachedFile.path) : Container(),
          padding: null,
        ),
        optionRow("RO", _cachedFlag1),
        optionRow("FR", _cachedFlag2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: buildLayoutBody(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () async {
          await _downloadFile();
//        await _downloadFlag();
        },
        tooltip: 'Increment',
        child: new Icon(Icons.cloud_download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

List<String> flagNames = <String>['RO.svg', 'FR.svg', 'AC.svg', 'BG.svg'];
