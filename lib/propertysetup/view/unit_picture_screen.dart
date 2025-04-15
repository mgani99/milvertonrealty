import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'dart:io'; // For handling file paths
import 'package:image_picker/image_picker.dart'; // To pick images
import 'package:milvertonrealty/utils/google_drive.dart';





class UnitPictureScreen extends StatefulWidget {
  final Map<String, dynamic> propertyData;

  const UnitPictureScreen({super.key, required this.propertyData});

  @override
  _UnitPictureScreenState createState() => _UnitPictureScreenState();
}
class AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
class _UnitPictureScreenState extends State<UnitPictureScreen> {
  final GoogleDriveManager driveManager = GoogleDriveManager();
  String unitName = "";
  bool _isSaving= false;
  Map<String, List<File>> roomImages = {
    'Bathroom': [],
    'Hallway': [],
    'Kitchen': [],
    'Living Room': [],
  };

  @override
  void didChangeDependencies () {
    super.didChangeDependencies();
    int bedroom  = widget.propertyData['bedrooms'] ?? 0;
    if (bedroom >= 1) {
      for (int i=0; i< bedroom; i++) {
        roomImages['Bedroom' + i.toString()] = [];
      }
    }
    else {
      roomImages.remove('Bedroom');
    }
    this.unitName = widget.propertyData['unitName'];
  }


  final ImagePicker _picker = ImagePicker();

   Future<void> _pickImage(String room) async {
     // if (kIsWeb) {
     //   // Web: Use HTML File Picker
     //   final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
     //   uploadInput.accept = 'image/*';
     //   uploadInput.click();
     //
     //   final Completer<Map<String, dynamic>> completer = Completer();
     //
     //   uploadInput.onChange.listen((event) async {
     //     final files = uploadInput.files;
     //     if (files != null && files.isNotEmpty) {
     //       final file = files[0];
     //       final reader = html.FileReader();
     //       reader.readAsDataUrl(file);
     //       reader.onLoadEnd.listen((_) {
     //         completer.complete({"name": file.name, "imageFile": reader.result});
     //       });
     //       final Map<String, dynamic> filemap = await completer.future;
     //       File f = filemap['imageFile'];
     //       roomImages[room] = [f];
     //       //roomImages[room] = [file];
     //     } else {
     //       completer.complete({"error": "No file selected"});
     //     }
     //   });
     //
     //   //return completer.future;
     // }
     // else {

     if (kIsWeb) {
       Uint8List? bytes;
       String? name;
       // On the web, use file_picker which returns the file bytes.
       FilePickerResult? result = await FilePicker.platform.pickFiles(
         type: FileType.image,
         allowMultiple: false,
       );
       if (result != null && result.files.isNotEmpty) {
         List<File> tempFiles = [];
         List<Uint8List> _webImages = [];
         for (var platformFile in result.files) {
           // Check if a file path is available (non-web platforms).
           if (platformFile.path != null) {
             File file = File(platformFile.path!);
             tempFiles.add(file);
           }
         }
         // final file = result.files.first;
         // bytes = file.bytes;
         // name = file.name;
         setState(() {
           roomImages[room]!.addAll(tempFiles);
         });
       }
     }
     else {
       final List<XFile>? pickedFile =
       await _picker.pickMultiImage();
       if (pickedFile != null && pickedFile.isNotEmpty) {
         setState(() {
           roomImages[room]!.addAll(
               pickedFile.map((xfile) => File(xfile.path)).toList());
         });
       }
     }
  }

  void _deleteImage(String room, int index) {
    setState(() {
      roomImages[room]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decorated Upload Button'),
      ),
      body: _isSaving ? CircularProgressIndicator() :Column(
        children: [
          Expanded(
            child: ListView(
              children: roomImages.entries.map((entry) {
                final roomName = entry.key;
                final images = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          roomName,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Display each uploaded image with a delete button and room label
                            ...images.asMap().entries.map((entry) {
                              final index = entry.key;
                              final imageFile = entry.value;

                              return Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Image.file(
                                      imageFile,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    child: Text(
                                      roomName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        backgroundColor: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 2,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteImage(roomName, index),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            // Add decorated "Upload Picture" button
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () => _pickImage(roomName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent, // Button color
                                  foregroundColor: Colors.white, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  elevation: 5.0, // Adds shadow
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.upload, size: 18),
                                    SizedBox(width: 5),
                                    Text('Upload'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isSaving = true;
                });
                await driveManager.signIn();
                var walkthruFolder = await driveManager.findOrCreateFolderInSharedFolder("1wimM_M3dY1Ooz-KjMXD1hbdj0yq1ncp2", "Walkthru");
                var unitFolderId = await driveManager.findOrCreateFolderInSharedFolder(walkthruFolder, unitName);
                roomImages.forEach((key, values) async {
                  final roomName = key;
                  final images = values;

                  var roomFolderId = await driveManager.findOrCreateFolderInSharedFolder(unitFolderId, roomName);

                    images.forEach((img) async{
                      await driveManager.uploadFileFolder(roomFolderId,img);
                    });
                  });
                setState(() {
                  _isSaving = false;
                });

                },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 5.0, // Adds shadow
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload, size: 18),
                  SizedBox(width: 5),
                  Text('Save in Google'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
