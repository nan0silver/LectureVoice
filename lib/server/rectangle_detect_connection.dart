import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class RectangleDetectConnection {

  var baseurl = 'http://127.0.0.1:5000';
  var rectangleDio = Dio();

  Future<List<dynamic>> rectangleDetectorRequest () async {
    try {
      Response response = await rectangleDio.get('$baseurl/process_image');
      String responseString = response.data;
      debugPrint("==Rectangle debugPrint==");
      debugPrint(responseString);
      debugPrint("=======RRRRRRRRRR=======");

      List<dynamic> data = jsonDecode(response.data);

      debugPrint("Rectangle done!!");
      return data;
    } catch (e) {
      debugPrint("Rectangle e start");
      debugPrint(e as String?);
      debugPrint("Rectangle fail!!");
      List<List<dynamic>> error = [[e]];
      return error;
    }
  }

}
//=======================================================================================================================================//

// import 'package:http/http.dart' as http;
//
// class ImageProcessingClient extends StatefulWidget {
//   @override
//   _ImageProcessingClientState createState() => _ImageProcessingClientState();
// }
//
// class _ImageProcessingClientState extends State<ImageProcessingClient> {
//   String _processedImageBase64 = '';
//
//   Future<void> processImage() async {
//     // Load the image from assets (Replace 'image.png' with your image file in assets)
//     ByteData imageData = await rootBundle.load('assets/image.png');
//     List<int> imageBytes = imageData.buffer.asUint8List();
//
//     // Convert the image bytes to base64
//     String imageBase64 = base64Encode(imageBytes);
//
//     // Send the image to the server
//     String url = 'http://your_server_ip:5000/process_image';
//     Map<String, String> headers = {'Content-Type': 'application/json'};
//     Map<String, dynamic> data = {'image': imageBase64};
//
//     http.Response response = await http.post(url, headers: headers, body: jsonEncode(data));
//
//     // Decode the processed image from the response
//     Map<String, dynamic> responseData = jsonDecode(response.body);
//     String processedImageBase64 = responseData['image'];
//
//     // Set the state with the processed image base64
//     setState(() {
//       _processedImageBase64 = processedImageBase64;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Processing Client'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: processImage,
//               child: Text('Process Image'),
//             ),
//             if (_processedImageBase64.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Image.memory(base64Decode(_processedImageBase64)),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
