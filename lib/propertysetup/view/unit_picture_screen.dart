import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io'; // For handling file paths
import 'package:image_picker/image_picker.dart'; // To pick images
import 'package:image_picker/image_picker.dart';
import 'package:milvertonrealty/utils/google_drive.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decorated Upload Button',
      home: UnitPictureScreen(),
    );
  }
}

class UnitPictureScreen extends StatefulWidget {
  @override
  _UnitPictureScreenState createState() => _UnitPictureScreenState();
}
class AuthenticatedClient extends BaseClient {
  final Map<String, String> _headers;
  final Client _client = Client();

  AuthenticatedClient(this._headers);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
class _UnitPictureScreenState extends State<UnitPictureScreen> {
  final GoogleDriveManager driveManager = GoogleDriveManager();
  final String unitName = "A1";
  bool _isSaving= false;
  final Map<String, List<File>> roomImages = {
    'Bedroom': [],
    'Bathroom': [],
    'Hallway': [],
    'Kitchen': [],
    'Living Room': [],
  };

  final ImagePicker _picker = ImagePicker();

   Future<void> _pickImage(String room) async {
    final List<XFile>? pickedFile =
    await _picker.pickMultiImage();
    if (pickedFile != null && pickedFile.isNotEmpty) {
      setState(() {
        roomImages[room]!.addAll(pickedFile.map((xfile) => File(xfile.path)).toList());
      });
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
