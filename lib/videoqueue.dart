// videoqueue.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoQueueModel extends ChangeNotifier {
  // ignore: prefer_final_fields
  ConcatenatingAudioSource _videoQueue = ConcatenatingAudioSource(children: []);
  int _currentIndex = 0;

   Video? _video;
  
  int get currentIndex => _currentIndex;
  ConcatenatingAudioSource get videoQueue => _videoQueue;

  void addToQueue(Video video) {
    getAudioSource(video);
  }
  void getAudioSource(Video video) async{
    var youtube = YoutubeExplode();
    StreamManifest streamManifest;
    try {
      streamManifest = await youtube.videos.streamsClient.getManifest(video.url);
    } catch (e) {
      return;
    }
    var audio=AudioSource.uri(streamManifest.audioOnly.withHighestBitrate().url,tag: MediaItem(
    id: video.id.value,
    album: video.author,
    title: video.title,
    artUri: Uri.parse(video.thumbnails.highResUrl)
  
  ),);
  _videoQueue.add(audio);
  notifyListeners();

  }
  void removeFromQueue(int index) {
    _videoQueue.removeAt(index);
    notifyListeners();
  }
  void clear(){
    _videoQueue.clear();
    notifyListeners();
  }
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
  void setCurrentVideo(Video video) {
    _video=video;
    videoQueue.clear();
  }
  Video? getCurrentVideo() {
    return _video;
    
  }
}
