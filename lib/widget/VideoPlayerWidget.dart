import 'package:chewie/chewie.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl, Key? key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool isMuted = true;

  bool isErrorOccurred = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  void toggleMute() {
    if (this.mounted) {
      setState(() {
        isMuted = !isMuted;
        _chewieController!.setVolume(isMuted ? 0.0 : 1.0);
      });
    }
  }

  Future<void> initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl);

      _videoPlayerController!.initialize().then((_) {
        if (this.mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController!,
              // autoPlay: true,
              looping: true,
              showControls: false,
            );

            _chewieController!.setVolume(isMuted ? 0.0 : 1.0);
          });
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
            isErrorOccurred = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    double videoHeight;

    if(Device.get().isTablet) {
      videoHeight = MediaQuery.of(context).size.height * 1.1;
    }
    else {
      videoHeight = MediaQuery.of(context).size.height * 0.8;
    }


    return isErrorOccurred? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 300,),
            IconButton(
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (this.mounted) {
                    isErrorOccurred = false;
                  }                    
                });
                try {
                  _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
                  _videoPlayerController!.initialize().then((_) {
                    if (this.mounted) {
                      setState(() {
                        _chewieController = ChewieController(
                          videoPlayerController: _videoPlayerController!,
                          looping: true,
                          showControls: false,
                        );

                        _chewieController!.setVolume(isMuted ? 0.0 : 1.0);
                      });
                    }
                  });
                } catch(e) {
                  if (this.mounted) {
                    setState(() {
                      isErrorOccurred = true;
                    });
                  }
                }
              },
              icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey),
            ),
            Text(
              "failed to load",
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey),
            ),
          ],
        ),
      ) : VisibilityDetector(
      key: Key('videoPlayerKey${widget.videoUrl}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          if (this.mounted) {
            _videoPlayerController!.pause();
          }
        } else {
          if (this.mounted) {
            _videoPlayerController!.play();
          }
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: toggleMute,
            child: SizedBox(
              height: videoHeight,
              child: _videoPlayerController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    )
                  : Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: IconButton(
              onPressed: toggleMute,
              icon: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    try {
      if (_videoPlayerController != null && _chewieController != null) {
        _videoPlayerController!.dispose();
        _chewieController!.dispose();
      }
      if (this.mounted) {
        super.dispose();
      }
    } catch(e) {
      if (this.mounted) {
        setState(() {
            isErrorOccurred = true;
        });
      }
    }
  
  }
}
