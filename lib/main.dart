import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

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
  File _cachedImage, _cachedSound;
  AudioPlayer audioPlayer;
  final int countriesLength = 319;
  int countryID = 12;
  String messageOutput = '';

  DocumentSnapshot _countryData;
  String fakeCountry = "";

  bool coin = false;

  List<dynamic> countryListFakes;

  Future<Null> _downloadImage() async {
    final String imgName = "$countryID.jpg";
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$imgName');
    print("image: " + imgName);
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("images/" + imgName);
    // downloading
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
    final int byteNumber = (await downloadTask.future).totalByteCount;

    setState(() => _cachedImage = file);
  }

  Future<Null> _downloadMusic() async {
    audioPlayer.stop();

    final String soundName = "${countryID}_x264.mp4";
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$soundName');
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("sounds/" + soundName);
    // downloading
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
    final int byteNumber = (await downloadTask.future).totalByteCount;

    _cachedSound = file;
    play();
  }

  getLayoutBody() {
    optionRow(bool isCorrectAnswer) {
      if (_countryData == null) return Container();

      return new Padding(
        padding: new EdgeInsets.only(top: 8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new RaisedButton(
              child: isCorrectAnswer
                  ? new Text(_countryData["country"])
                  : new Text(fakeCountry),
              color: Theme.of(context).buttonColor,
              elevation: 2.0,
              onPressed: () {
                // Perform some action
                setState(() {
                  messageOutput = isCorrectAnswer
                      ? '${_countryData["country"]} is corect! \n'
                          '${_countryData["img_title"]}'
                      : 'Nope! The correct answer is ${_countryData["country"]}!';
                });
              },
            ),
          ],
        ),
      );
    }

    return new Column(
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: _cachedImage != null
              ? Image.asset(_cachedImage.path)
              : Container(),
        ),
        optionRow(coin),
        optionRow(!coin),
        new Padding(
          padding: new EdgeInsets.only(top: 16.0),
          child: new Text(
            '$messageOutput',
          ),
        )
      ],
    );
  }

  updateCountryData() {
    Firestore.instance
        .collection('sights_and_sounds_')
        .document(countryID.toString())
//        .where("topic", isEqualTo: "flutter")
        .snapshots()
        .listen((data) {
      print(data["country"]);
      setState(() {
        _countryData = data;
        coin = Random().nextBool();
      });
    });
    return;
  }

  play() async {
    await audioPlayer.play(_cachedSound.path, isLocal: true);
  }

  moveToNextCountry() async {
    cleanUI();
    countryID = Random().nextInt(countriesLength) + 2;
    await _downloadImage();
    await _downloadMusic();
    updateCountryData();
    getRandomFakeCountry();
  }

  @override
  void initState() {
    super.initState();
    audioPlayer = new AudioPlayer();
    loadAssetCountryListFakes();
    moveToNextCountry();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: getLayoutBody(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          moveToNextCountry();
        },
        tooltip: 'Increment',
        child: new Icon(Icons.cloud_download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String> loadAssetCountryListFakes() async {
    String data = await rootBundle.loadString('assets/countrycodes.json');
    countryListFakes = json.decode(data)['countrycodes'];
    getRandomFakeCountry();
  }

  getRandomFakeCountry() {
    setState(() {
      int n = Random().nextInt(countryListFakes.length);
      fakeCountry = countryListFakes[n]['name'];
//      print(fakeCountry);
    });
  }

  void cleanUI() {
    setState(() {
      _cachedImage = null;
      _cachedSound = null;
      audioPlayer.stop();
      messageOutput = '';

      _countryData = null;
      fakeCountry = '';
    });
  }
}
