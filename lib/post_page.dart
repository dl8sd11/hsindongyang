import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hsindongyang/photo_api.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  Future<void> download(PhotoApi api) async {
    api.updatePostDate();
    final postDate = DateFormat('yyyy/MM/dd').format(api.postDate);
    final prefs = await SharedPreferences.getInstance();
    final content = prefs.getString('content-$postDate') ?? "";
    await Clipboard.setData(ClipboardData(text: content));
    final images = prefs.getStringList('images-$postDate') ?? [];
    api.downloadImages(images);
  }

  Future<void> done(PhotoApi api) async {
    api.advancePostDate();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('next-post-date', api.postDate.toString());
  }

  @override
  Widget build(BuildContext context) {
    PhotoApi api = context.watch<PhotoApi>();
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                download(api);
              },
              child: const Text("Download")),
          ElevatedButton(
              onPressed: () {
                done(api);
              },
              child: const Text("Done")),
        ],
      ),
    ));
  }
}
