// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/docs/v1.dart' as docs;
// import 'package:extension_google_sign_in_as_googleapis_auth.dart';
//
// Future<void> generateLease(String documentId, String tenantName, String rentAmount) async {
//   final googleSignIn = GoogleSignIn(scopes:);
//   final account = await googleSignIn.signIn();
//   final httpClient = await account?.authenticatedClient();
//   if (httpClient == null) {
//     // Handle authentication failure
//     return;
//   }
//   final docsApi = docs.DocsApi(httpClient);
//   final requests =;
//   final batchUpdateRequest = docs.BatchUpdateDocumentRequest(requests: requests);
//   try {
//     final response = await docsApi.documents.batchUpdate(batchUpdateRequest, documentId);
//     print('Document updated: ${response.documentId}');
//     // Proceed to get shareable link
//   } catch (e) {
//     print('Error updating document: $e');
//     // Handle error
//   }
// }