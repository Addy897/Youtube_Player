import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:yt/videoqueue.dart';
import 'package:yt/yt_home_page.dart';
import 'package:provider/provider.dart';
void main() async {
    await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoQueueModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtube Premium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const YTHomePage(title: 'Youtube Premium'),
    );
  }
}

