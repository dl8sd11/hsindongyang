import 'dart:io';
import 'package:dio/dio.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/photoslibrary/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:hsindongyang/face_service.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoApi extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[PhotosLibraryApi.photoslibraryReadonlyScope],
  );
  GoogleSignInAccount? currentUser;
  PhotosLibraryApi? photosLibraryApi;
  bool isSignedIn = false;
  List<Album>? albums;
  List<MediaItem> images = [];
  DateTime fetchDate = DateTime.now();
  DateTime postDate = DateTime.now();

  PhotoApi() {
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      currentUser = account;
      if (currentUser != null) {
        initPhotoLibraryApi();
      }
    });
    googleSignIn.signInSilently();
    updatePostDate();
  }

  void advanceFetchDate() {
    fetchDate = fetchDate.add(const Duration(days: 2));
    notifyListeners();
  }

  void advancePostDate() {
    postDate = postDate.add(const Duration(days: 2));
    notifyListeners();
  }

  Future<void> updatePostDate() async {
    final prefs = await SharedPreferences.getInstance();
    final nextPostDate = prefs.getString('next-post-date');
    postDate =
        nextPostDate != null ? DateTime.parse(nextPostDate) : DateTime.now();
  }

  Future<void> initPhotoLibraryApi() async {
    final auth.AuthClient? client = await googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');
    photosLibraryApi = PhotosLibraryApi(client!);
    if (photosLibraryApi == null) return;
    isSignedIn = true;
    albums = (await photosLibraryApi!.sharedAlbums.list()).sharedAlbums;
    notifyListeners();
  }

  Future<void> signIn() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      print(error); // ignore: avoid_print
    }
  }

  Future<void> signOut() async {
    await googleSignIn.disconnect();
    photosLibraryApi = null;
    currentUser = null;
    isSignedIn = false;
    notifyListeners();
  }

  Future<void> prepareImage(String? faceFilter) async {
    final prefs = await SharedPreferences.getInstance();
    final albumId = prefs.getString('albumId');
    fetchDate = DateTime.parse(prefs.getString('next-edit-date') ?? '');

    final currentDate = fetchDate;
    String? pageToken;
    List<MediaItem> allImages = [];
    while (true) {
      SearchMediaItemsResponse response;
      response = await photosLibraryApi!.mediaItems.search(
          SearchMediaItemsRequest(
              albumId: albumId, pageToken: pageToken, pageSize: 100));
      allImages += response.mediaItems ?? [];
      pageToken = response.nextPageToken;
      final lastDate =
          DateTime.parse(allImages.last.mediaMetadata?.creationTime ?? "");
      if (pageToken == null ||
          DateUtils.dateOnly(lastDate)
              .isBefore(DateUtils.dateOnly(currentDate))) {
        break;
      }
    }
    images = allImages.where((element) {
      return DateUtils.isSameDay(
          DateTime.parse(element.mediaMetadata?.creationTime ?? ""),
          currentDate);
    }).toList();

    final faceService = FaceRecognitionService();

    if (faceFilter != null) {
      List<MediaItem> filtered = [];
      for (var image in images) {
        final result =
            await faceService.recognizeFaces("${image.baseUrl}=w364", "amazon");
        final items = result["amazon"]["items"];
        if (items == null || items.length == 0) {
          continue;
        }
        if (items[0]["face_id"] == faceFilter) {
          filtered.add(image);
        }
      }
      images = filtered;
    }

    notifyListeners();
  }

  Future<void> downloadImages(List<String> imageIds) async {
    final imagesResponse =
        await photosLibraryApi?.mediaItems.batchGet(mediaItemIds: imageIds);
    List<MediaItemResult> images = imagesResponse?.mediaItemResults ?? [];

    Dio dio = Dio();
    try {
      var path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_PICTURES);

      final dir = Directory('$path/Hsindongyang');
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          await entity.delete();
        }
      }

      var index = 0;
      for (final image in images) {
        final url = image.mediaItem?.baseUrl;
        if (url != null) {
          final path = '${dir.path}/$index.jpg';
          await dio.download(
            '$url=d',
            path,
          );
          index++;
        }
        MediaScanner.loadMedia(path: path);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
