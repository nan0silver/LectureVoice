import 'dart:async';
import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:second_flutter_app/firebase_options.dart';

class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest({
    Key? key,
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
    Key? key,
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

  final byteData = await rootBundle.load("asset/video/test_pythonLecture.mp4");
  //asset/video/OS_cutfile_11sec.mp4
  Directory tempDir = await getTemporaryDirectory();

  File tempVideo = File("${tempDir.path}/asset/video/test_pythonLecture.mp4")
    ..createSync(recursive: true)
    ..writeAsBytesSync(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  var thumbnailPath1;

  try {
    thumbnailPath1 = await VideoThumbnail.thumbnailFile(
        //video: r.video,
        video: tempVideo.path,
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
  } on Exception catch (e) {
    print("thumnailPath error is = $e");
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

// Future<ThumbnailResult> genThumbnailAgain(ThumbnailRequest r) async{
//   //final responseAgain;
//   Completer<ThumbnailResult> responseAgain = Completer();
//
//   try {
//     responseAgain = (await genThumbnail(r)) as Completer<ThumbnailResult>;
//
//
//   }catch(e){
//       debugPrint("genThumbnailAgain Error = $e");
//   }
//
//   return responseAgain.future;
// }

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;
  final Key? key;

  const GenThumbnailImage({required this.thumbnailRequest, required this.key}) : super(key: key);

  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  late Future<ThumbnailResult> genThumbnailFuture;

  @override
  void initState() {
    genThumbnailFuture = genThumbnail(widget.thumbnailRequest);
    //genThumbnailFuture = genThumbnailAgain(widget.thumbnailRequest);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("_GenThumbnailImageState start");

    return FutureBuilder<ThumbnailResult>(
      future: genThumbnailFuture, //genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
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
            Reference _ref = _storage.ref("test/image__$_whattime");
            _ref.putData(_image_unit8, SettableMetadata(contentType: "image/jpeg"));
          } on Exception catch (e) {
            debugPrint("Firebase Storage PUT data error = $e");
          }

          debugPrint("image size width = $_width");

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.memory(_image_unit8, width: 150,),
              Center(
                  child: Text("$hour:$min:$sec"),
                ),
            ],
          );
        }
        // else if (snapshot.connectionState == ConnectionState.waiting) {
        //   print("로딩중");
        //   return Container(
        //       padding: EdgeInsets.all(8.0),
        //       color: Colors.yellow,
        //       child: Center(
        //         child: CircularProgressIndicator(),
        //       )
        //   );
        // }
        else if (snapshot.hasError) {
          print("Error ${snapshot.error.toString()}");

          return Container(
            padding: EdgeInsets.all(8.0),
            //color: Colors.red,
            child: Center(
              child: CircularProgressIndicator(),
            )
          );
        } else {
          print("썸네일 생성중...");
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                    "Generating the thumbnail..."),
                SizedBox(
                  height: 10.0,
                ),
                CircularProgressIndicator(),
              ]);
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