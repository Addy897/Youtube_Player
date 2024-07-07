import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt/videoapp.dart';
import 'package:yt/videoqueue.dart';

class YTHomePage extends StatefulWidget {
  const YTHomePage({super.key, required this.title});

  final String title;

  @override
  State<YTHomePage> createState() => _YTHomePageState();
}

class _YTHomePageState extends State<YTHomePage> {
  int _selectedIndex = 0;
  Timer? _timer;
  Duration? _duration;
  List<Widget> resp = List.generate(1, (i) {
    return const Center(child: CircularProgressIndicator());
  });
  @override
  void initState() {
    super.initState();
    getVideos("Trending Songs");
  }

  void getVideos(text) async {
    var yt = YoutubeExplode();
    var videos = await yt.search.search(text);

    setState(() {
      resp = List.generate(videos.length, (i) {
        return ListTile(
          title:  Text(videos[i].title),
          subtitle: Text("${videos[i].engagement.viewCount.toString()} views"),
          leading: Image.network(videos[i].thumbnails.highResUrl),
          trailing: IconButton(icon: const Icon(Icons.queue_music),onPressed: () {
            Provider.of<VideoQueueModel>(context,listen: false).addToQueue(videos[i]);
            const SnackBar(content: Text("Added to queue"));
          },),
          onTap: () {
            Provider.of<VideoQueueModel>(context, listen: false).setCurrentVideo(videos[i]);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const VideoApp()),
            );
          },
        );
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var navbar = ['Youtube', 'Time'];
    var navItems = List.generate(navbar.length, (i) {
      return ListTile(
        title: Text(navbar[i]),
        selected: _selectedIndex == i,
        selectedColor: Colors.redAccent,
        onTap: () {
          Navigator.pop(context);
          _onItemTapped(i);
        },
      );
    });
    List<Widget> widgetOptions = <Widget>[
      ListView(
        children: [
          // Input Box
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
                onSubmitted: (value) {
                  setState(() {
                    resp = List.generate(1, (i) {
                      return const Center(child: CircularProgressIndicator());
                    });
                  });
                  getVideos(value);
                },
              )),
          ...resp,
        ],
      ),
      Center(
        child: Column(
          children: [
            _duration!=null?TimerCountdown(endTime:DateTime.now().add(_duration??const Duration(seconds: 0)) ):const Text("Set Timer"),
            IconButton(onPressed: setTime, icon: const Icon(Icons.timer))
          ],
        ),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: Colors.redAccent,
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontFamily: "monospace"),
        ),
      ),
      body: widgetOptions[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Center(
                  child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: 'Made on Mars',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "monospace")),
                WidgetSpan(
                    child: Icon(
                  Icons.face,
                  color: Colors.white,
                ))
              ]))),
            ),
            ...navItems,
          ],
        ),
      ),
    );
  }

  void setTime() async {
 showTimePicker(
  initialTime: TimeOfDay.now(),
  context: context,
).then((value){

setState(() {
  _duration= Duration(hours: value!.hour-TimeOfDay.now().hour,minutes: value.minute-TimeOfDay.now().minute).abs();

  if(_timer!=null){
    _timer?.cancel();
    
  }
  _timer=Timer(_duration??const Duration(seconds: 0), () {_timer=null;exit(0); });
  });

}).catchError((e){
  _timer=null;
});  
  
  }
}
