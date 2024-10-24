import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../screen/result_screen.dart';
import '../server/scenedetector_connection.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final GestureTapCallback onNewVideoPressed;

  const CustomVideoPlayer({
    Key? key,
    required this.video,
    required this.onNewVideoPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  bool showControls = false;
  VideoPlayerController? videoController;
  SceneDetectorConnection _sceneDetectorConnection = SceneDetectorConnection();

  late String _tempDir;
  late List<String> timeline_tonextpage = [];
  late List<int> millitime_tonextpage = [];
  late List<String> imageURL_tonextpage = [];
  late Future<List<String>> _parsingVideoFuture;  // 수정: String으로 변경

  @override
  void initState() {
    super.initState();

    // 임시 디렉토리 설정
    getTemporaryDirectory().then((dir) async {
      _tempDir = dir.path;
      print("Temporary directory: $_tempDir");

      initializeController().then((_) {
        if (mounted) {
          setState(() {
            _parsingVideoFuture = getPysceneResultSequential();
          });
        }
      }).catchError((error) {
        print("Video controller initialization failed: $error");
      });
    });
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
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return Center(child: CircularProgressIndicator());
    }
    ScrollController _scrollController = ScrollController();

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
            aspectRatio: videoController!.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(videoController!),
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
                            onChanged: (double val) {
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
              ],
            ),
          ),
        ),
        Container(
          color: Colors.black26,
          height: 2,
        ),

        // 동영상 재생기 밑에 썸네일 이미지 나오는 부분
        Container(
          height: 500,
          color: Colors.white30,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: 10,
            child: FutureBuilder<List<String>>(
              future: _parsingVideoFuture,
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error!!'),
                  );
                } else {
                  List<String> thumbnailUrls = snapshot.data ?? [];

                  return ListView.separated(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, color: Colors.black),
                    itemCount: thumbnailUrls.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // 수직 및 수평 여백 추가
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // 이미지와 타임스탬프의 수평 정렬
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 타임스탬프와 이미지 사이의 여백 조정
                          children: [
                            // 타임스탬프 텍스트
                            Container(
                              padding: EdgeInsets.all(7.0),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.2), // 배경색 추가
                                borderRadius: BorderRadius.circular(12), // 둥근 모서리 추가
                                boxShadow: [
                                  // BoxShadow(
                                  //   color: Colors.black12,
                                  //   offset: Offset(2, 2),
                                  //   blurRadius: 4,
                                  // ),
                                ],
                              ),
                              child: Text(
                                "${timeline_tonextpage[index]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'RobotoMono', // 특정 폰트를 사용하고 싶다면 추가 가능
                                ),
                              ),
                            ),

                            // 이미지
                            Container(
                              width: 300,  // 이미지 크기 조절
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset(0, 5), // 그림자 효과
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10), // 둥근 모서리 적용
                                child: Image.network(
                                  thumbnailUrls[index], // Firebase에 저장된 URL로부터 이미지 출력
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text('Error loading image');
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                    },
                  );
                }
              },
            ),
          ),
        ),
        Container(
          color: Colors.white,
          height: 10,
        ),
        Container(
          color: Colors.black26,
          height: 2,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10,),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (timeline_tonextpage.isNotEmpty && millitime_tonextpage.isNotEmpty && imageURL_tonextpage.isNotEmpty) {
                      // ResultScreen 페이지로 데이터 전달
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            timeline: timeline_tonextpage,
                            millitime: millitime_tonextpage,
                            imageURLList: imageURL_tonextpage,
                          ),
                        ),
                      );
                    } else {
                      print("Error: The imageURLList or timeline is empty.");
                    }
                  },
                  child: Text(
                    'Next Step',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(128, 151, 213, 50),
                  ),
                ),
              ),
              SizedBox(width: 10,),
            ],
          ),
        ),


      ],
    );
  }

  Future<List<String>> getPysceneResultSequential() async {
    File videoFile = File(widget.video.path);
    int videoNameinFirebase = DateTime.now().millisecondsSinceEpoch;
    String refVideoFirebase = "videos/$videoNameinFirebase";

    // Firebase에 비디오 업로드
    await FirebaseStorage.instance.ref(refVideoFirebase).putFile(videoFile);
    final String videoUrl = await FirebaseStorage.instance.ref(refVideoFirebase).getDownloadURL();

    // Scene Detector 결과 받기
    List<dynamic> result = await _sceneDetectorConnection.sceneDetectorRequest(videoUrl);

    List<int> resultStartTime = [];
    List<String> thumbnailUrls = [];

    for (int i = 0; i < result.length; i++) {
      String startTime = result[i][0];
      List<String> timeSplit = startTime.split(':');
      int hour = int.parse(timeSplit[0]);
      int min = int.parse(timeSplit[1]);
      String sec = timeSplit[2];
      List<String> secList = sec.split('.');
      int secFront = int.parse(secList[0]);
      int secBack = int.parse(secList[1]);

      int timeMilli = (hour * 60 * 60 * 1000) + (min * 60 * 1000) + (secFront * 1000) + secBack + 1;
      resultStartTime.add(timeMilli);
      millitime_tonextpage.add(timeMilli);
      timeline_tonextpage.add("$hour:$min:$secFront");

      // 각 썸네일을 Firebase에 업로드 후 URL을 저장
      String thumbnailUrl = await createThumbnailSequentially(videoUrl, timeMilli);
      thumbnailUrls.add(thumbnailUrl);
    }

    return thumbnailUrls;  // 썸네일 URL 리스트 반환
  }

  Future<String> createThumbnailSequentially(String videoUrl, int timeMs) async {
    String? thumbnailPath;
    String thumbnailUrl = '';
    int retryCount = 0;
    const int maxRetries = 3;  // 최대 재시도 횟수

    while (retryCount < maxRetries) {
      try {
        // 1. 비디오에서 특정 타임스탬프(timeMs)에서 썸네일 이미지 생성
        thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoUrl,
          thumbnailPath: _tempDir,
          imageFormat: ImageFormat.JPEG,
          timeMs: timeMs,
          quality: 100,
        );

        // 썸네일 생성 실패 시 예외 처리
        if (thumbnailPath == null) {
          throw Exception('Failed to generate thumbnail');
        }

        // 2. 생성된 썸네일 이미지를 Firebase에 업로드
        try {
          File thumbnailFile = File(thumbnailPath);
          String refImageFirebase = "sceneImage/image__$timeMs";
          await FirebaseStorage.instance.ref(refImageFirebase).putFile(thumbnailFile);

          // 3. Firebase에 업로드된 이미지의 다운로드 URL을 가져옴
          thumbnailUrl = await FirebaseStorage.instance.ref(refImageFirebase).getDownloadURL();
          print("Successfully uploaded thumbnail: $thumbnailUrl");

          // 추출된 이미지의 URL을 저장하는 리스트에 추가
          imageURL_tonextpage.add(thumbnailUrl);

          // 업로드가 성공하면 재시도 루프에서 벗어남
          break;

        } on FirebaseException catch (firebaseError) {
          print("Firebase Storage upload failed: $firebaseError");
          retryCount++;
        } on Exception catch (e) {
          print("Error during Firebase upload: $e");
          retryCount++;
        }

      } on Exception catch (e) {
        retryCount++;
        print("Failed to generate thumbnail at timeMs: $timeMs with error: $e (Retry $retryCount/$maxRetries)");

        // 재시도 횟수 초과 시 오류 로그 남기고 진행
        if (retryCount >= maxRetries) {
          print("Max retries reached. Skipping timeMs: $timeMs");
          return 'Failed';
        }
      }
    }

    return thumbnailUrl;
  }


  Widget renderTimeTextFromDuration(Duration duration) {
    return Text(
      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
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
    } else {
      videoController!.play();
    }
  }

  void onForwardPressed() {
    final maxPosition = videoController!.value.duration;
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds > currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }
}



// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:second_flutter_app/screen/image_processing_screen.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';
// import 'package:second_flutter_app/component/custom_icon_button.dart';
// import 'package:second_flutter_app/component/custom_video_thumbnail.dart';
// import 'package:second_flutter_app/server/scenedetector_connection.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:second_flutter_app/screen/lecture_text_screen.dart';
//
// import '../screen/result_screen.dart';
//
// //동영상이 선택된 후 나타나는 페이지
// //오직 넘겨받은 강의내용 파일 + 동영상으로 재생만 해줌
// //========= 4-1 페이지 ==========//
//
// class CustomVideoPlayer extends StatefulWidget {
//   final XFile video;
//   final GestureTapCallback onNewVideoPressed;
//   //final List<Image> images;
//
//   const CustomVideoPlayer({
//     Key? key,
//     required this.video, //갤러리에서 선택된 동영상
//     required this.onNewVideoPressed, //갤러리에서 동영상 선택
//     //required this.images,
//   }) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _CustomVideoPlayerState();
// }
//
// class _CustomVideoPlayerState extends State<CustomVideoPlayer>{
//   bool showControls = false;
//   VideoPlayerController? videoController;
//
//   SceneDetectorConnection _sceneDetectorConnection = SceneDetectorConnection();
//
//   XFile? video;
//   late String _tempDir;
//   late List<String> timeline_tonextpage=[];
//   late List<int> millitime_tonextpage=[];
//   late List<String> imageURL_tonextpage=[];
//   late String resultLength = "_";
//   late int resultCount = 0;
//
//   late Future<List<GenThumbnailImage>> _parsingVideoFuture;
//
//
//   //새로운 동영상 선택되면 update
//   @override
//   void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (oldWidget.video.path != widget.video.path) {
//       initializeController();
//     }
//   }
//
//   Future<void> ensureDirectoryExists(String path) async {
//     final directory = Directory(path);
//     if (!await directory.exists()) {
//       await directory.create(recursive: true);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 임시 디렉토리 설정
//     getTemporaryDirectory().then((dir) async {
//       _tempDir = dir.path;
//       await ensureDirectoryExists(_tempDir); // 디렉토리 존재 확인 후 생성
//       print("Temporary directory: $_tempDir");
//
//       initializeController().then((_) {
//         if (mounted) {  // mounted를 통해 위젯이 활성 상태인지 확인
//           setState(() {
//             _parsingVideoFuture = getPysceneResultSequential();
//           });
//         }
//       }).catchError((error) {
//         print("Video controller initialization failed: $error");
//       });
//     });
//
//
//   }
//
//   initializeController() async {
//     final videoController = VideoPlayerController.file(
//       File(widget.video.path),
//     );
//
//     await videoController.initialize();
//
//     videoController.addListener(videoControllerListener);
//
//     setState(() {
//       this.videoController = videoController;
//     });
//   }
//
//   void videoControllerListener() {
//     setState(() {}); //build 재실행
//   }
//
//   @override
//   void dispose() {
//     videoController?.removeListener(videoControllerListener);
//     super.dispose();
//   } //state 폐기될때 처리함수
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   Widget build(BuildContext context) {
//     if (videoController == null) {
//       return Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//     ScrollController _scrollController = ScrollController();
//
//     return Column(
//             children: [
//               SizedBox(
//                 width: double.infinity,
//                 height: 80,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showControls = !showControls;
//                   });
//                 },
//                 child: AspectRatio(
//                   aspectRatio: videoController!.value.aspectRatio,
//                   child: Stack(
//                     children: [
//                       VideoPlayer(
//                         videoController!,
//                       ),
//                       if (showControls)
//                         Container(
//                           color: Colors.black.withOpacity(0.5),
//                         ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         left: 0,
//                         child: Padding( //동영상 재생바
//                           padding: EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Row(
//                             children: [
//                               renderTimeTextFromDuration(
//                                 videoController!.value.position,
//                               ),
//                               Expanded(
//                                 child: Slider(
//                                   onChanged: (double val){
//                                     videoController!.seekTo(
//                                       Duration(seconds: val.toInt()),
//                                     );
//                                   },
//                                   value: videoController!.value.position.inSeconds.toDouble(),
//                                   min: 0,
//                                   max: videoController!.value.duration.inSeconds.toDouble(),
//                                 ),
//                               ),
//                               renderTimeTextFromDuration(
//                                 videoController!.value.duration,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // 다른 동영상을 바로 재생할 수 있는 기능 삭제
//                       // if (showControls)
//                       //   Align(
//                       //     alignment: Alignment.topRight,
//                       //     child: CustomIconButton(
//                       //       onPressed: widget.onNewVideoPressed,
//                       //       iconData: Icons.photo_camera_back,
//                       //     ),
//                       //   ),
//
//                       if (showControls)
//                         Align(
//                           alignment: Alignment.center,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               CustomIconButton(onPressed: onReversePressed, iconData: Icons.rotate_left,),
//                               CustomIconButton(onPressed: onPlayPressed,
//                                 iconData: videoController!.value.isPlaying?
//                                 Icons.pause : Icons.play_arrow,),
//                               CustomIconButton(onPressed: onForwardPressed, iconData: Icons.rotate_right,)
//                             ],
//                           ),
//                         )
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 color: Colors.black26,
//                 height: 2,
//               ),
//
//               //=====동영상 재생기 밑에 강의 내용 나오는 부분=====//
//               Container(
//                     height: 500,
//                     color: Colors.white30,
//                     child: Scrollbar(
//                       controller: _scrollController,
//                       thumbVisibility: true,
//                       thickness: 10,
//                       child:FutureBuilder<List<GenThumbnailImage>>( //List<GenThumbnailImage>
//                               future: _parsingVideoFuture, //getPysceneResult(),
//                               builder: (BuildContext context, AsyncSnapshot<List<GenThumbnailImage>> snapshot) {
//
//                                 //late List<GenThumbnailImage> thumbnailFutureList = snapshot.data;
//                                 if (snapshot.connectionState != ConnectionState.done) {
//                                   return Center(
//                                     child: SizedBox(
//                                         width: 35,
//                                         height: 35,
//                                         child: CircularProgressIndicator(),
//                                       //동글동글 돌아가는 로딩서클
//                                     ),
//                                   );
//
//                                 }
//                                 else if (snapshot.hasError) {
//                                   print(snapshot.error);
//                                   return Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'Error!!'
//                                     ),
//                                   );
//                                 }
//                                 else {
//                                   List<GenThumbnailImage> thumbnailFutureList = snapshot.data ?? [];
//                                   return ListView.separated(
//                                       controller: _scrollController,
//                                       shrinkWrap: true,
//                                       scrollDirection: Axis.vertical,
//                                       separatorBuilder: (BuildContext context, int index) =>
//                                           const Divider(height: 1, color: Colors.black,), //separatorBuilder : item과 item 사이에 그려질 위젯 (개수는 itemCount -1 이 된다)
//                                       itemCount: thumbnailFutureList.length,
//                                       itemBuilder: (BuildContext context, int index) {
//                                         return Row(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: <Widget>[Center(
//                                             child: Text(
//                                               "[${index+1}]",
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                                 fontSize: 20,
//                                               ),
//                                             ),
//                                           ),
//                                             thumbnailFutureList[index],
//                                           ],
//                                         );
//                                       }
//                                   );
//                                 }
//                               }
//                           )
//
//                       ),
//                     ),
//               Container(
//                 color: Colors.white,
//                 height: 10,
//               ),
//               Container(
//                 color: Colors.black26,
//                 height: 2,
//               ),
//               Expanded( //이미지 정보 나오는 부분
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // ElevatedButton(
//                       //   onPressed: () async {
//                       //     downloadThumbnail();
//                       //   }, child: const Text("확인"),
//                       // ),
//                       SizedBox(width: 10,),
//                       SizedBox(
//                         height: 50,
//                         child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => ResultScreen(
//                                   timeline: timeline_tonextpage,
//                                   millitime: millitime_tonextpage,
//                                   imageURLList: imageURL_tonextpage,)),
//                               );
//                             },
//                             child: Text(
//                               'Next Step',
//                               style: TextStyle(
//                                 //fontSize: 25,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Color.fromRGBO(128, 151, 213, 50),
//                             )
//                         ),
//                       ),
//                       SizedBox(width: 10,),
//                     ],
//                   )
//               )
//
//             ]
//         );
//   }
//
//   Future<List<GenThumbnailImage>> getPysceneResult() async {
//
//     //Store video to the firebase DB
//     File videoFile = File(widget.video.path);
//     int videoNameinFirebase = DateTime.now().millisecondsSinceEpoch;
//     String refVideoFirebase = "videos/$videoNameinFirebase";
//
//     await FirebaseStorage.instance.ref(refVideoFirebase).putFile(videoFile);
//     final String video_path = await FirebaseStorage.instance.ref(refVideoFirebase).getDownloadURL();
//
//     //Scene Detector 결과 받기
//     List<dynamic> result = await _sceneDetectorConnection.sceneDetectorRequest(video_path);
//
//     print("get scene detector result success");
//     print("scene detector result length : ${result.length}");
//     resultLength = result.length.toString();
//
//     List<int> resultStartTime = [];
//     List<GenThumbnailImage> thumbnailImageList = [];
//
//     timeline_tonextpage=[];
//     millitime_tonextpage=[];
//
//     //밀리초로 변환
//     for (int i = 0; i < result.length; i++) {
//       int timeMilli = 0;
//       String startTime = result[i][0];
//       print("startTime = $startTime");
//       List<String> timeSplit = startTime.split(':');
//       int hour = int.parse(timeSplit[0]);
//       int min = int.parse(timeSplit[1]);
//       String sec = timeSplit[2];
//       print("hour = $hour, min = $min, sec = $sec");
//       List<String> secList = sec.split('.');
//       int secFront = int.parse(secList[0]);
//       //secFront++; //1초 더함
//       int secBack = int.parse(secList[1]);
//       print("secFront = $secFront, secBack = $secBack");
//
//       timeMilli = (hour*60*60*1000) + (min*60*1000) + (secFront*1000) + secBack+1;
//       print(timeMilli);
//       timeline_tonextpage.add("$hour:$min:$secFront");
//       millitime_tonextpage.add(timeMilli);
//
//       resultStartTime.add(timeMilli);
//     }
//
//     //썸네일 이미지 생성
//     for (int i = 0; i < result.length; i++) {
//       GenThumbnailImage thumbnailImage = GenThumbnailImage(
//         thumbnailRequest: ThumbnailRequest(
//           video: video_path,
//           thumbnailPath: _tempDir,
//           imageFormat: ImageFormat.JPEG,
//           maxHeight: 1000,
//           maxWidth: 1000,
//           timeMs: resultStartTime[i],
//           quality: 100,
//         ),
//       );
//
//       thumbnailImageList.add(thumbnailImage);
//       print("now thumnailImageList length = $i");
//     }
//
//     print("step end");
//
//     //썸네일 이미지가 저장된 firebase의 url을 리스트에 저장
//     //다음 페이지인 lecture text screen에서 수행하고 ocr에 url을 넘기려고 하니가 순서가 꼬임
//     //그냥 여기서 저장해서 다음 페이지에 넘겨주는 방법이 간편할 것으로 보임
//     //result.length == 5
//
//     imageURL_tonextpage=[];
//
//     int length = thumbnailImageList.length;
//     print("** thumbnailImageList final length = $length **");
//     resultCount = length;
//
//     //return result; //1차원 list
//     return thumbnailImageList;
//   }
//
//   Future<List<GenThumbnailImage>> getPysceneResultSequential() async {
//     File videoFile = File(widget.video.path);
//     int videoNameinFirebase = DateTime.now().millisecondsSinceEpoch;
//     String refVideoFirebase = "videos/$videoNameinFirebase";
//
//     // Firebase에 비디오 업로드
//     await FirebaseStorage.instance.ref(refVideoFirebase).putFile(videoFile);
//     final String videoUrl = await FirebaseStorage.instance.ref(refVideoFirebase).getDownloadURL();
//
//     // Scene Detector 결과 받기
//     List<dynamic> result = await _sceneDetectorConnection.sceneDetectorRequest(videoUrl);
//
//     List<int> resultStartTime = [];
//     List<GenThumbnailImage> thumbnailImageList = [];
//
//     for (int i = 0; i < result.length; i++) {
//       String startTime = result[i][0];
//       List<String> timeSplit = startTime.split(':');
//       int hour = int.parse(timeSplit[0]);
//       int min = int.parse(timeSplit[1]);
//       String sec = timeSplit[2];
//       List<String> secList = sec.split('.');
//       int secFront = int.parse(secList[0]);
//       int secBack = int.parse(secList[1]);
//
//       int timeMilli = (hour * 60 * 60 * 1000) + (min * 60 * 1000) + (secFront * 1000) + secBack+1;
//       resultStartTime.add(timeMilli);
//       millitime_tonextpage.add(timeMilli);
//       timeline_tonextpage.add("$hour:$min:$secFront");
//     }
//
//     // 순차적으로 썸네일 생성 및 업로드
//     for (int i = 0; i < result.length; i++) {
//       GenThumbnailImage thumbnailImage = await createThumbnailSequentially(videoUrl, resultStartTime[i]);
//       thumbnailImageList.add(thumbnailImage);
//     }
//
//     return thumbnailImageList;
//   }
//
//   Future<GenThumbnailImage> createThumbnailSequentially(String videoUrl, int timeMs) async {
//     String? thumbnailPath;
//     int retryCount = 0;
//     const int maxRetries = 3;
//
//     while (retryCount < maxRetries) {
//       try {
//         // 썸네일 파일 생성
//         thumbnailPath = await VideoThumbnail.thumbnailFile(
//           video: videoUrl,
//           thumbnailPath: _tempDir,
//           imageFormat: ImageFormat.JPEG,
//           timeMs: timeMs,
//           quality: 100,
//         );
//
//         if (thumbnailPath == null) {
//           throw Exception('Failed to generate thumbnail');
//         }
//
//         // Firebase에 썸네일 업로드
//         try {
//           File thumbnailFile = File(thumbnailPath);
//           String refImageFirebase = "sceneImage/image__$timeMs";
//           await FirebaseStorage.instance.ref(refImageFirebase).putFile(thumbnailFile);
//           String thumbnailUrl = await FirebaseStorage.instance.ref(refImageFirebase).getDownloadURL();
//           imageURL_tonextpage.add(thumbnailUrl);
//           print("Successfully uploaded thumbnail: $thumbnailUrl");
//           break; // 성공 시 반복 종료
//         } on FirebaseException catch (firebaseError) {
//           print("Firebase Storage upload failed: $firebaseError");
//         } on Exception catch (e) {
//           print("Error during Firebase upload: $e");
//         }
//
//       } on Exception catch (e) {
//         retryCount++;
//         print("Failed to generate thumbnail at timeMs: $timeMs with error: $e (Retry $retryCount/$maxRetries)");
//
//         // 재시도 횟수 초과 시 오류 로그 남기고 진행
//         if (retryCount >= maxRetries) {
//           print("Max retries reached. Skipping timeMs: $timeMs");
//         }
//       }
//     }
//
//     return GenThumbnailImage(
//       thumbnailRequest: ThumbnailRequest(
//         video: videoUrl,
//         thumbnailPath: thumbnailPath ?? 'default/path',  // null일 때 대체 경로 설정
//         imageFormat: ImageFormat.JPEG,
//         maxHeight: 1000,
//         maxWidth: 1000,
//         timeMs: timeMs,
//         quality: 100,
//       ),
//     );
//   }
//
//
//
