import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';


class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest({
    //Key? key,
    required this.video,
    required this.thumbnailPath,
    required this.imageFormat,
    required this.maxHeight,
    required this.maxWidth,
    required this.timeMs,
    required this.quality
  });
}

class ThumbnailResult {
  final Uint8List image_unit8;
  final Image image;
  final int dataSize;
  final int height;
  final int width;
  final int whattime;

  const ThumbnailResult({
    //Key? key,
    required this.image_unit8,
    required this.image,
    required this.dataSize,
    required this.height,
    required this.width,
    required this.whattime
  });
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  //WidgetsFlutterBinding.ensureInitialized();
  Uint8List? bytes;
  final Completer<ThumbnailResult> completer = Completer();

  print("genThumbnail start");


  var thumbnailPath1;

  try {

    if (r.thumbnailPath == null || r.thumbnailPath.isEmpty) {
      print("Invalid thumbnail path.");
    } else {
      print("Thumbnail path is valid.");
    }
    
    thumbnailPath1 = await VideoThumbnail.thumbnailFile(
        video: r.video,
        headers: {
          "USERHEADER1": "user defined header1",
          "USERHEADER2": "user defined header2",
        },
        thumbnailPath: r.thumbnailPath,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);


    print("custom Video Thumbnail r.video : ${r.video}");
  } on Exception catch (e) {
    print("thumbnailPath error is = $e");
  }

  int whatTime = r.timeMs;

  print("thumbnail file is located: $thumbnailPath1");
  print("now thumbnail file time is : $whatTime");

  final file = File(thumbnailPath1!);
  bytes = file.readAsBytesSync();

  int _imageDataSize = bytes!.length;
  print("image size: $_imageDataSize");

  final _image = Image.memory(bytes!);
  _image.image
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(ThumbnailResult(
      image_unit8: bytes!,
      image: _image,
      dataSize: _imageDataSize,
      height: info.image.height,
      width: info.image.width,
      whattime: whatTime,
    ));
  }));

  // await Future.delayed(Duration(seconds: 3));
  // debugPrint("딜레이!");
  return completer.future;
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  //final Key? key;

  const GenThumbnailImage({
    required this.thumbnailRequest,

    //required this.key
  }) : super(
      //key: key
  );

  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> with AutomaticKeepAliveClientMixin{
  late Future<ThumbnailResult> genThumbnailFuture;
  late Future<String> imageUrlFuture;

  @override
  void initState() {
    super.initState();
    genThumbnailFuture = genThumbnail(widget.thumbnailRequest);
    //imageUrlFuture = genThumbnailFuture.then((result) => _uploadToFirebase(result));

  }

  @override
  bool get wantKeepAlive => true;

  // Future<String> _uploadToFirebase(ThumbnailResult result) async {
  //   try {
  //     FirebaseStorage _storage = FirebaseStorage.instance;
  //     String fileName = "sceneImage/image__${result.whattime}.jpg";
  //     Reference _ref = _storage.ref(fileName);
  //
  //     // Firebase에 이미지 업로드
  //     await _ref.putData(result.image_unit8, SettableMetadata(contentType: "image/jpeg"));
  //
  //     // 업로드된 이미지의 URL 가져오기
  //     String downloadUrl = await _ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch (e) {
  //     debugPrint("Firebase Storage PUT data error = $e");
  //     throw e;
  //   }
  // }
  String _formatTime(int milliseconds) {
    var duration = Duration(milliseconds: milliseconds);
    var hours = duration.inHours.toString().padLeft(2, '0');
    var minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    var seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    debugPrint("_GenThumbnailImageState start");

    super.build(context);
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnailFuture, //genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final _image_unit8 = snapshot.data.image_unit8;
          final _image = snapshot.data.image;
          final _width = snapshot.data.width;
          final _height = snapshot.data.height;
          final _dataSize = snapshot.data.dataSize;
          final _whattime = snapshot.data.whattime;

          var hour = ((_whattime / (1000 * 60 *60 )) % 24 ).toInt();
          var min = ((_whattime / (1000 * 60 )) % 60 ).toInt();
          var sec = ((_whattime / 1000 ) % 60).toInt();

          try {
            FirebaseStorage _storage = FirebaseStorage.instance;
            Reference _ref = _storage.ref("sceneImage/image__$_whattime");
            _ref.putData(_image_unit8, SettableMetadata(contentType: "image/jpeg"));
          } on Exception catch (e) {
            debugPrint("Firebase Storage PUT data error = $e");
          }

          debugPrint("image size width = $_width");

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.memory(_image_unit8, width: 300,),
              SizedBox(width: 10,),
              Center(
                  child: Text(
                      "$hour:$min:$sec",
                    style: TextStyle(
                      //fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          );
          // final ThumbnailResult result = snapshot.data!;
          // final formattedTime = _formatTime(result.whattime);
          //
          // return Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: <Widget>[
          //     FutureBuilder<String>(
          //       future: imageUrlFuture,
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.waiting) {
          //           return CircularProgressIndicator();
          //         } else if (snapshot.hasError) {
          //           return Icon(Icons.error);
          //         } else if (snapshot.hasData) {
          //           //return Image.memory(result.image_unit8, width: 300);
          //           return Image.network(snapshot.data!, width: 300);
          //         } else {
          //           return CircularProgressIndicator();
          //         }
          //       },
          //     ),
          //     SizedBox(width: 10),
          //     Center(
          //       child: Text(
          //         formattedTime,
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           color: Colors.black,
          //         ),
          //       ),
          //     ),
          //   ],
          // );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class ImageInFile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}