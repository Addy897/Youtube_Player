
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt/videoqueue.dart';

class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> with WidgetsBindingObserver {
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  static AudioPlayer? _player;  
  late ConcatenatingAudioSource _audioSource;
  late Widget player;
  Video? _video;
  void getAudioSource() async{

  }
  void _init() async {
    var youtube = YoutubeExplode();
    _video= Provider.of<VideoQueueModel>(context,listen: false).getCurrentVideo();
    StreamManifest streamManifest;
    try {
      streamManifest =
          await youtube.videos.streamsClient.getManifest(_video?.url);
    } catch (e) {
      setState(() {
        player = Center(child: Text("Error Ocurred : $e"));
      });
      return;
    }
    StreamInfo videoStream;

    if(_video!.isLive){
        videoStream=streamManifest.streams.first;
    }else{
      videoStream = streamManifest.muxed.bestQuality;
    }
    var source=AudioSource.uri(streamManifest.audioOnly.withHighestBitrate().url,tag: MediaItem(
    id: _video!.id.value,
    album: _video?.author,
    title: _video!.title,
    artUri: Uri.parse(_video!.thumbnails.highResUrl)
  
  ),);
    videoController = VideoPlayerController.networkUrl(
      videoStream.url,
      videoPlayerOptions: VideoPlayerOptions(
          webOptions: const VideoPlayerWebOptions(
              controls: VideoPlayerWebOptionsControls.enabled(allowDownload: true,allowFullscreen: true,allowPictureInPicture: true,allowPlaybackRate: true))),
    );
    await videoController?.initialize();
    setState(() {
      if (videoController != null) {
        chewieController = ChewieController(
          videoPlayerController: videoController ??
              VideoPlayerController.networkUrl(Uri.parse("")),
          autoPlay: true,
          isLive: _video!.isLive,
        );
        player = Chewie(
          controller: chewieController ?? ChewieController.of(context),
        );
      }
    });
      Provider.of<VideoQueueModel>(context,listen: false).videoQueue.add(source);
    _audioSource= Provider.of<VideoQueueModel>(context,listen: false).videoQueue;

    _player = AudioPlayer();
    

  
  }

  @override
  void initState() {
    super.initState();
    stopAudio();
    _player?.dispose();
    WidgetsBinding.instance.addObserver(this);
    _init();
    player = const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(!videoController!.value.isPlaying){
            _player?.dispose();

    }else{
      startAudio();
    }
    videoController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }
  void startAudio(){
    _player?.setAudioSource(_audioSource,initialPosition: videoController?.value.position);
    _player!.setLoopMode(LoopMode.all);
    _player!.setShuffleModeEnabled(true);
     _player?.play();
  }
  void stopAudio(){
      _player?.stop();
  }
@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state==AppLifecycleState.paused){
        startAudio();
    }
    if(state==AppLifecycleState.resumed){
      if(_player!.playing){
            videoController?.seekTo(_player!.position);
      }
      stopAudio();


    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_video!.title),
        ),
        body: Column(children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: player,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(_video!.title),
                Text("\n${_video?.description}\n"),
                Text(_video!.author),
                Text(
                    "${_video?.uploadDate?.day.toString()}-${_video?.uploadDate?.month.toString()}-${_video?.uploadDate?.year.toString()} ${_video?.uploadDate?.hour.toString()}:${_video?.uploadDate?.minute.toString()}:${_video?.uploadDate?.second.toString()}")
              ],
            ),
          )
        ]));
  }
}

