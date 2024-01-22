import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:second_flutter_app/screen/image_processing_screen.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:second_flutter_app/component/custom_icon_button.dart';
import 'package:second_flutter_app/component/custom_video_thumbnail.dart';
import 'package:second_flutter_app/server/scenedetector_connection.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:second_flutter_app/screen/lecture_text_screen.dart';

//동영상이 선택된 후 나타나는 페이지
//오직 넘겨받은 강의내용 파일 + 동영상으로 재생만 해줌
//========= 4-1 페이지 ==========//

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final GestureTapCallback onNewVideoPressed;
  //final List<Image> images;

  const CustomVideoPlayer({
    Key? key,
    required this.video, //갤러리에서 선택된 동영상
    required this.onNewVideoPressed, //갤러리에서 동영상 선택
    //required this.images,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>{
  bool showControls = false;
  VideoPlayerController? videoController;

  SceneDetectorConnection _sceneDetectorConnection = SceneDetectorConnection();

  XFile? video;
  late String _tempDir;
  late List<String> timeline_tonextpage;
  late List<int> millitime_tonextpage;
  late List<String> imageURL_tonextpage;
  late String resultLength = "_";

  late Future<List<GenThumbnailImage>> parsingVideoFuture;

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
    parsingVideoFuture = getPysceneResult();
    super.initState();
    initializeController();
    getTemporaryDirectory().then((d) => _tempDir = d.path);
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
                        child: Padding( //동영상 재생바
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

                      // 다른 동영상을 바로 재생할 수 있는 기능 삭제
                      // if (showControls)
                      //   Align(
                      //     alignment: Alignment.topRight,
                      //     child: CustomIconButton(
                      //       onPressed: widget.onNewVideoPressed,
                      //       iconData: Icons.photo_camera_back,
                      //     ),
                      //   ),

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
              SizedBox(
                height: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                  ),
                ),
              ),

              //=====동영상 재생기 밑에 강의 내용 나오는 부분=====//
              Container(
                    height: 150,
                    color: Colors.white,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 10,
                      child:FutureBuilder<List<GenThumbnailImage>>(
                              future: parsingVideoFuture, //getPysceneResult(),
                              builder: (BuildContext context, AsyncSnapshot<List<GenThumbnailImage>> snapshot) {

                                //late List<GenThumbnailImage> thumbnailFutureList = snapshot.data;
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return Center(child: SizedBox(width: 35, height: 35, child: CircularProgressIndicator()),);
                                  //동글동글 돌아가는 로딩서클
                                }
                                else if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Error!!'
                                    ),
                                  );
                                }
                                else {
                                  List<GenThumbnailImage> thumbnailFutureList = snapshot.data ?? [];
                                  return ListView.separated(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (BuildContext context, int index) =>
                                      const Divider(height: 1,), //separatorBuilder : item과 item 사이에 그려질 위젯 (개수는 itemCount -1 이 된다)
                                      itemCount: thumbnailFutureList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Column(
                                          children: <Widget>[
                                            //(_futreImage != null) ? _futreImage : SizedBox(),
                                            // (thumbnailFutureList != null)
                                            //     ? thumbnailFutureList[index]
                                            //     : SizedBox(),
                                            thumbnailFutureList[index]
                                          ],
                                        );
                                      }
                                  );
                                  // return Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Text(
                                  //     snapshot.data.toString(),
                                  //     style: TextStyle(fontSize: 15),
                                  //   ),
                                  // );
                                }
                              }
                          )

                      ),
                    ),

              Expanded( //이미지 정보 나오는 부분
                  child: Column(
                    children: [
                      Text(
                      '선택하신 동영상은 \n 총 ${videoController!.value.duration.inMinutes.toString()}분 '
                          '${(videoController!.value.duration.inSeconds % 60).toString().padLeft(2,'0')}초 입니다\n',
                      style: TextStyle(
                      color: Colors.black,
                      ),),
                      Text(
                        "해당 동영상의 장면은 총 $resultLength개 입니다. \n 장면을 문서로 변환하길 원하시면 아래 버튼을 눌러주세요.\n",
                        style: TextStyle(
                          color: Colors.black
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LectureTextScreen(
                                  timeline: timeline_tonextpage,
                                  millitime: millitime_tonextpage,
                                  imageURLList: imageURL_tonextpage,)),
                              );
                            },
                            child: Text(
                              '강의 문서로 만들기',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(128, 151, 213, 50),
                            )
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ImageProcessingScreen(
                                  timeline: timeline_tonextpage,
                                  millitime: millitime_tonextpage,
                                  imageURLList: imageURL_tonextpage,)),
                              );
                            },
                            child: Text(
                              '이미지 처리하기',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(128, 151, 213, 50),
                            )
                        ),
                      ),
                    ],
                  )
              )

            ]
        );
  }

  Future<List<GenThumbnailImage>> getPysceneResult() async {

    //Store video to the firebase DB
    File videoFile = File(widget.video.path);
    int videoNameinFirebase = DateTime.now().millisecondsSinceEpoch;
    String refVideoFirebase = "videos/$videoNameinFirebase";

    await FirebaseStorage.instance.ref(refVideoFirebase).putFile(videoFile);
    final String video_path = await FirebaseStorage.instance.ref(refVideoFirebase).getDownloadURL();


    List<dynamic> result = await _sceneDetectorConnection.sceneDetectorRequest(video_path);

    print("get scendetector result success");
    print(result.length);
    resultLength = result.length.toString();

    List<int> resultStartTime = [];
    List<GenThumbnailImage> thumbnailImageList = [];

    final _video = TextEditingController(text: "asset/video/test_pythonLecture.mp4"); //이게 뭔지.. 신경 안써도 될듯
    //asset/video/OS_cutfile_11sec.mp4
    //asset/video/test_pythonLecture.mp4
    ImageFormat _format = ImageFormat.JPEG;
    int _quality = 80;
    int _sizeH = 500;
    int _sizeW = 500;
    int _timeMs = 0;

    late GenThumbnailImage _futreImage = GenThumbnailImage(
      key: UniqueKey(),
      thumbnailRequest: ThumbnailRequest(
        video: _video.text,
        thumbnailPath: "null",
        imageFormat: _format,
        maxHeight: _sizeH,
        maxWidth: _sizeW,
        timeMs: _timeMs,
        quality: _quality,
      ),
    );

    timeline_tonextpage=[];
    millitime_tonextpage=[];

    //밀리초로 변환
    for (int i = 0; i < result.length; i++) {
      int timeMilli = 0;
      String startTime = result[i][0];
      print("startTime = $startTime");
      List<String> timeSplit = startTime.split(':');
      int hour = int.parse(timeSplit[0]);
      int min = int.parse(timeSplit[1]);
      String sec = timeSplit[2];
      print("hour = $hour, min = $min, sec = $sec");
      List<String> secList = sec.split('.');
      int secFront = int.parse(secList[0]);
      //secFront++; //1초 더함
      int secBack = int.parse(secList[1]);
      print("secFront = $secFront, secBack = $secBack");

      timeMilli = (hour*60*60*1000) + (min*60*1000) + (secFront*1000) + secBack+1;
      print(timeMilli);
      timeline_tonextpage.add("$hour:$min:$secFront");
      millitime_tonextpage.add(timeMilli);

      resultStartTime.add(timeMilli);
    }

    //썸네일 생성해 리스트에 추가
    //int i = 0; i < result.length; i++
    for (int i = 0; i < result.length; i++) {
      GenThumbnailImage _futreImage = await loadFutureImage(
          ThumbnailRequest(
              video: _video.text,
              thumbnailPath: _tempDir,
              imageFormat: _format,
              maxHeight: _sizeH,
              maxWidth: _sizeW,
              timeMs: resultStartTime[i],
              quality: _quality));

      // GenThumbnailImage _futreImage = await GenThumbnailImage(
      //     key: UniqueKey(),
      //     thumbnailRequest: ThumbnailRequest(
      //         video: _video.text,
      //         thumbnailPath: _tempDir,
      //         imageFormat: _format,
      //         maxHeight: _sizeH,
      //         maxWidth: _sizeW,
      //         timeMs: resultStartTime[i],
      //         quality: _quality));
      thumbnailImageList.add(_futreImage);
      print("_video.text = ${_video.text}");
      print("now thumnailImageList length = $i");
    }

    //아직은 파이어베이스에 이미지 저장 안함
    //내가 임의로 저장해놓은 파일 사용

    //await FirebaseStorage.instance.ref(refVideoFirebase).putFile(videoFile);
    FirebaseStorage _storage = FirebaseStorage.instance;
    Reference _ref = _storage.ref("test/text3");
    _ref.putString("Hello World !!");

    print("step end");

    //썸네일 이미지가 저장된 firebase의 url을 리스트에 저장
    //다음 페이지인 lecture text screen에서 수행하고 ocr에 url을 넘기려고 하니가 순서가 꼬임
    //그냥 여기서 저장해서 다음 페이지에 넘겨주는 방법이 간편할 것으로 보임
    //result.length == 5

    imageURL_tonextpage=[];

    for (int i = 0; i < result.length; i++) {
      int tempMillTime = millitime_tonextpage[i];

      Reference _ref = FirebaseStorage.instance.ref().child("test/image__$tempMillTime.png");
      String _thumbnailImageURL = await _ref.getDownloadURL();
      print("thumbnail image url = $_thumbnailImageURL");
      imageURL_tonextpage.add(_thumbnailImageURL);
    }

    int length = thumbnailImageList.length;
    print("thumbnailImageList final length = $length");
    print("thumbnail image url list final length = ${imageURL_tonextpage.length}");
    //return result; //1차원 list
    return thumbnailImageList;
  }

  Future<GenThumbnailImage> loadFutureImage(ThumbnailRequest r) async{

    GenThumbnailImage futreImage = await GenThumbnailImage(
        key: UniqueKey(),
        thumbnailRequest: r);

    return futreImage;

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