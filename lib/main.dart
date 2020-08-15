import 'dart:async';
import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Music Player'),
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

  List<Musique> maListeDeMusiques = [
    new Musique('Theme Swift', 'Brice Hache', 'assets/images/un.jpg', 'assets/audios/un.mp3'),
    new Musique('Theme Flutter', 'Brice Hache', 'assets/images/deux.jpg', 'assets/audios/deux.mp3'),
  ];

  AudioPlayer audioPlayer;
  Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);

  PlayerState statut = PlayerState.stopped;

  StreamSubscription positionsub;
  StreamSubscription stateSubscription;

  int index = 0;

  @override
  void initState(){
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[index];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 1.5),
            texteAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton((statut == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 45.0, (statut == PlayerState.playing) ? ActionMusic.pause: ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle(fromDuration(position), 0.8),
                texteAvecStyle(fromDuration(duree), 0.8),
              ],
            ),

            new Slider(
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: 30.0,
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d){
                setState(() {
                  audioPlayer.seek(d);
                });
              }
            ),

          ],
        )


      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action){
    return new IconButton(
      iconSize: taille,
      color: Colors.white,
      icon: new Icon(icone),
      onPressed: (){
        switch (action){
          case ActionMusic.play:
            play();
            break;
          case ActionMusic.pause:
            pause();
            break;
          case ActionMusic.forward:
            forward();
            break;
          case ActionMusic.rewind:
            rewind();
            break;
        }
      },
    );
  }

  Text texteAvecStyle(String data, double scale){
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 28.0,
        fontStyle: FontStyle.italic
      )
    );
  }



  void configurationAudioPlayer(){
    audioPlayer = new AudioPlayer();

    positionsub = audioPlayer.onAudioPositionChanged.listen(
            (pos) => setState(() => position = pos)
    );

    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
        duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (msg) {
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });

  }

  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() async {
    if(index == maListeDeMusiques.length - 1){
      index = 0;
    }else{
      index++;
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() async{
    if(position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    }else{
      if(index == 0){
        index = maListeDeMusiques.length - 1;
      }else{
        index--;
      }
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  String fromDuration(Duration duree){
    return duree.toString().split('.').first;
  }




}

enum ActionMusic{
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused

}