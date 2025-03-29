
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';


class GoogleDriveManager {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      // Permission to access Drive files
    ],
  );

  GoogleSignInAccount? _currentUser;

  Future<void> signIn() async {
    _currentUser = await _googleSignIn.signIn();
    if (_currentUser == null) {
      throw Exception("Google Sign-In was canceled by the user.");
    }
    print("User signed in: ${_currentUser!.email}");
  }

  Future<void> uploadFileToSharedFolder(String folderId, File file) async {
    if (_currentUser == null) {
      throw Exception("User is not signed in.");
    }

    // Authenticate and create the Drive API client
    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = AuthenticatedClient(authHeaders);

    final driveApi = drive.DriveApi(authenticatedClient);

    // Create metadata for the file
    var fileMetadata = drive.File();
    fileMetadata.name = file.uri.pathSegments.last; // Use the file's name
    fileMetadata.parents = [folderId]; // Specify the shared folder ID

    // Upload the file
    var media = drive.Media(file.openRead(), file.lengthSync());
    final uploadedFile = await driveApi.files.create(
      fileMetadata,
      uploadMedia: media,
    );

    print("File uploaded successfully! File ID: ${uploadedFile.id}");
  }

  Future<String> findOrCreateFolderInSharedFolder(String sharedFolderId,
      String folderName) async {
    if (_currentUser == null) {
      throw Exception("User is not signed in.");
    }

    // Authenticate and create the Drive API client
    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = AuthenticatedClient(authHeaders);

    final driveApi = drive.DriveApi(authenticatedClient);

    // Step 1: Search for the folder in the shared folder
    String query =
        "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder' and '$sharedFolderId' in parents";
    final searchResponse = await driveApi.files.list(q: query);

    if (searchResponse.files != null && searchResponse.files!.isNotEmpty) {
      print("Folder found: ${searchResponse.files!.first
          .name}, ID: ${searchResponse.files!.first.id}");
      return searchResponse.files!.first.id!;
    }

    // Step 2: Folder not found, create a new one
    var folder = drive.File();
    folder.name = folderName;
    folder.parents = [sharedFolderId];
    folder.mimeType = "application/vnd.google-apps.folder";

    final createdFolder = await driveApi.files.create(folder);

    print("Folder created: ${createdFolder.name}, ID: ${createdFolder.id}");
    return createdFolder.id!;
  }

  Future<void> uploadFileFolder(String folderId, File file) async {
    if (_currentUser == null) {
      throw Exception("User is not signed in.");
    }

    // Authenticate and create the Drive API client
    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = AuthenticatedClient(authHeaders);

    final driveApi = drive.DriveApi(authenticatedClient);
    var fileMetadata = drive.File();
    fileMetadata.name = file.uri.pathSegments.last; // Use the file's name
    fileMetadata.parents = [folderId]; // Specify the shared folder ID

    // Upload the file
    var media = drive.Media(file.openRead(), file.lengthSync());
    final uploadedFile = await driveApi.files.create(
      fileMetadata,
      uploadMedia: media,
    );
  }


  /*final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );
  Future<void> uploadToGoogleDrive() async {
    final account = await _googleSignIn.signIn();

    if (account == null) {
      return; // User canceled sign-in
    }

    final authHeaders = await account.authHeaders;
    final httpClient = http.Client();

    try {
      for (var category in uploadedImages.keys) {
        for (var imageFile in uploadedImages[category]!) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'),
          );
          String accessToken = authHeaders['Authorization']!;
          request.headers['Authorization'] = accessToken;
          request.headers['Content-Type'] = 'multipart/related; boundary=boundary';

          final metadata = {
            'name': imageFile.path.split('/').last,
            'mimeType': 'image/jpeg', // Replace with the correct MIME type
          };

          final metadataPart = http.MultipartFile.fromString(
            'metadata',
            jsonEncode(metadata),
            contentType: MediaType('application', 'json'),
          );

          final filePart = await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'), // Replace with the correct MIME type
          );
          print('$accessToken');



          //addAll(authHeaders);
          // request.fields['name'] = im  ageFile.path.split('/').last;
          // String? mimeType = lookupMimeType(imageFile.path);
          // request.fields['mimeType'] = mimeType ?? 'application/octet-stream';
          // //request.fields['mimeType'] = 'image/jpeg';

          // request.files.add(await http.MultipartFile.fromPath(
          //   'file',
          //   imageFile.path,
          // ));
          request.files.add(metadataPart);
          request.files.add(filePart);

          final response = await request.send();
          var strresponse = await http.Response.fromStream(response);
          print(request.files);
          if (response.statusCode == 200) {
            print('Image uploaded successfully: ${imageFile.path}');
          } else {

            print('Failed to upload image: ${strresponse.body}');
          }
        }
      }
    } finally {
      httpClient.close();
    }
  }*/
}
// AuthenticatedClient for making authenticated requests
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