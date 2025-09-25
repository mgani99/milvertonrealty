
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';


class GoogleDriveManager {
  List<String> usersEmail = ['mohammed.gani@gmail.com', 'tazman536@gmail.com', 'Faisol.islam@gmail.com'];
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
    shareFileWithUsers(driveApi: driveApi, fileId: uploadedFile.id!, userEmails: usersEmail);
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
    shareFileWithUsers(driveApi: driveApi, fileId: createdFolder.id!, userEmails: usersEmail);
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
    shareFileWithUsers(driveApi: driveApi, fileId: uploadedFile.id!, userEmails: usersEmail);
  }

  Future<void> uploadToDrive(
      drive.DriveApi driveApi,
      List<PlatformFile> files,
      ) async {
    for (final f in files) {
      final media = drive.Media(
        Stream.value(f.bytes!),  // raw bytes from file_picker
        f.bytes!.length,
      );
      final driveFile = drive.File()..name = f.name;
      await driveApi.files.create(driveFile, uploadMedia: media);
    }
  }

  Future<void> uploadFilesFromWeb(String folderId, List<PlatformFile> files) async {
    if (_currentUser == null) {
      throw Exception("User is not signed in.");
    }

    // Authenticate and create the Drive API client
    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = AuthenticatedClient(authHeaders);

    final driveApi = drive.DriveApi(authenticatedClient);
    for (final file in files) {
      final media = drive.Media(Stream.value(file.bytes!), file.bytes!.length,);
      final driveFile = drive.File()
        ..name = file.name;
      //await driveApi.files.create(driveFile, uploadMedia: media);
      var fileMetadata = driveFile;
      fileMetadata.name = file.name; // Use the file's name
      fileMetadata.parents = [folderId]; // Specify the shared folder ID

      // Upload the file
      //var media = drive.Media(file.openRead(), file.lengthSync());
      final uploadedFile = await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );
      shareFileWithUsers(
          driveApi: driveApi, fileId: uploadedFile.id!, userEmails: usersEmail);
    }
  }

  Future<String> uploadFileFromWeb(String folderId, PlatformFile file) async {
    if (_currentUser == null) {
      throw Exception("User is not signed in.");
    }

    // Authenticate and create the Drive API client
    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = AuthenticatedClient(authHeaders);

    final driveApi = drive.DriveApi(authenticatedClient);

      final media = drive.Media(Stream.value(file.bytes!), file.bytes!.length,);
      final driveFile = drive.File()
        ..name = file.name;
      //await driveApi.files.create(driveFile, uploadMedia: media);
      var fileMetadata = driveFile;
      fileMetadata.name = file.name; // Use the file's name
      fileMetadata.parents = [folderId]; // Specify the shared folder ID

      // Upload the file
      //var media = drive.Media(file.openRead(), file.lengthSync());
      final uploadedFile = await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );
      shareFileWithUsers(
          driveApi: driveApi, fileId: uploadedFile.id!, userEmails: usersEmail);

      return 'https://drive.google.com/uc?id=${uploadedFile.id}';
  }
  Future<String> uploadFile(Uint8List bytes, String filename) async {
    await signIn();
    final authHeaders = await _currentUser!.authHeaders;
    final client = authenticatedClient(
      Client(),
      AccessCredentials.fromJson(authHeaders),
    );

    final api = drive.DriveApi(client);
    final media = drive.Media(Stream.fromIterable([bytes]), bytes.length);
    final file = await api.files.create(
      drive.File()..name = filename,
      uploadMedia: media,
    );
    return 'https://drive.google.com/uc?id=${file.id}';
  }


  Future<void> shareFileWithUsers({
    required drive.DriveApi driveApi,
    required String fileId,
    required List<String> userEmails,
    String role = 'writer',
  }) async {
    for (final email in userEmails) {
      await shareFileWithUser(
        driveApi: driveApi,
        fileId: fileId,
        userEmail: email,
        role: role,
      );
    }
  }
  Future<void> shareFileWithUser({
    required drive.DriveApi driveApi,
    required String fileId,
    required String userEmail,
    String role = 'writer',                // 'reader', 'writer', 'commenter'
    bool sendNotificationEmail = true,     // send the share email
  }) async {
    final permission = drive.Permission()
      ..type = 'user'
      ..role = role
      ..emailAddress = userEmail;
    print('setting permission for ${fileId}');
    await driveApi.permissions.create(
      permission,
      fileId,
      sendNotificationEmail: sendNotificationEmail,
      supportsAllDrives: true,             // if you’re using Shared Drives
    );
  }
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