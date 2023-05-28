import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:second_flutter_app/component/custom_icon_button.dart';
import 'package:second_flutter_app/server/scenedetector_connection.dart';
import 'package:export_video_frame/export_video_frame.dart';

//동영상이 선택된 후 나타나는 페이지

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final GestureTapCallback onNewVideoPressed;
  //final List<Image> images;

  const CustomVideoPlayer({
    Key? key,
    required this.video,
    required this.onNewVideoPressed,
    //required this.images,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

class ImageItem extends StatelessWidget {
  ImageItem({required this.image}) : super(key: ObjectKey(image));
  final Image image;

  @override
  Widget build(BuildContext context) {
    return Container(child: image);
  }
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>{
  bool showControls = false;
  VideoPlayerController? videoController;

  SceneDetectorConnection _sceneDetectorConnection = SceneDetectorConnection();
  //Future<List<List<dynamic>>>? sceneResultFuture;

  //새로운 동영상 선택되면 update
  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video.path != widget.video.path) {
      initializeController();
    }
  }

  @override
  void initState() {
    super.initState();
    initializeController();
    //초기 선언에서 video controller가 생성
  }

  initializeController() async {
    final videoController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await videoController.initialize();

    videoController.addListener(videoControllerListener);

    setState(() {
      this.videoController = videoController;
    });
  }

  void videoControllerListener() {
    setState(() {}); //build 재실행
  }

  @override
  void dispose() {
    videoController?.removeListener(videoControllerListener);
    super.dispose();
  } //state 폐기될때 처리함수

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                showControls = !showControls;
              });
            },
            child: AspectRatio(
              aspectRatio: 4/3, //videoController!.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(
                    videoController!,
                  ),
                  if (showControls)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          renderTimeTextFromDuration(
                            videoController!.value.position,
                          ),
                          Expanded(
                            child: Slider(
                              onChanged: (double val){
                                videoController!.seekTo(
                                  Duration(seconds: val.toInt()),
                                );
                              },
                              value: videoController!.value.position.inSeconds.toDouble(),
                              min: 0,
                              max: videoController!.value.duration.inSeconds.toDouble(),
                            ),
                          ),
                          renderTimeTextFromDuration(
                            videoController!.value.duration,
                          )
                        ],
                      ),
                    ),
                  ),
                  if (showControls)
                    Align(
                      alignment: Alignment.topRight,
                      child: CustomIconButton(
                        onPressed: widget.onNewVideoPressed,
                        iconData: Icons.photo_camera_back,
                      ),
                    ),

                  if (showControls)
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomIconButton(onPressed: onReversePressed, iconData: Icons.rotate_left,),
                          CustomIconButton(onPressed: onPlayPressed,
                            iconData: videoController!.value.isPlaying?
                            Icons.pause : Icons.play_arrow,),
                          CustomIconButton(onPressed: onForwardPressed, iconData: Icons.rotate_right,)
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    "여기 ppt의 텍스트, 자료들의 설명이 출력됩니다.",
                    //SceneDetectorConnection().toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                      future: getPysceneResult(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData == false) {
                          return CircularProgressIndicator(); //동글동글 돌아가는 로딩서클
                        }
                        else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error!!'
                            ),
                          );
                        }
                        else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              snapshot.data.toString(),
                              style: TextStyle(fontSize: 15),
                            ),
                          );
                        }
                      }
                  )
                ]
              ),
            ),
          ),
          // Container(
          //   padding: EdgeInsets.zero,
          //   child: Column(
          //     children: <Widget>[
          //       Expanded(
          //       flex: 1,
          //       child: GridView.extent(
          //           maxCrossAxisExtent: 400,
          //           childAspectRatio: 1.0,
          //           padding: const EdgeInsets.all(4),
          //           mainAxisSpacing: 4,
          //           crossAxisSpacing: 4,
          //           children: widget.images.length > 0
          //               ? widget.images
          //               .map((image) => ImageItem(image: image))
          //               .toList()
          //               : [Container()]),
          //       ),
          //     ]
          //   )
          // )
        ]
    );
  }

  Future<List<dynamic>> getPysceneResult() async {
    //List<List<dynamic>> result= (await SceneDetectorConnection()) as List<List>;

    List<dynamic> result = await _sceneDetectorConnection.sceneDetectorRequest();

    print("111");
    //List<dynamic> parsedResult = parseVideoTimeline(result);
    return result; //1차원 list
  }

  List<dynamic> parseVideoTimeline(List<dynamic> response) {
    List<dynamic> result = [];

    for (int i = 0; i < response.length; i++) {
      response[i][0];
    }
    return result;
  }


  Widget renderTimeTextFromDuration(Duration duration) {
    return Text(
      '${duration.inMinutes.toString().padLeft(2,'0')}:${(duration.inSeconds % 60).toString().padLeft(2,'0')}',
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();

    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onPlayPressed() {
    if (videoController!.value.isPlaying) {
      videoController!.pause();
    }
    else {
      videoController!.play();
    }
  }

  void onForwardPressed() {
    final maxPosition = videoController!.value.duration; //!는 null check pointer
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds > currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }
}