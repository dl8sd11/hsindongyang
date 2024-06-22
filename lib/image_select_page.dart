import 'package:flutter/material.dart';
import 'package:hsindongyang/edit_content_page.dart';
import 'package:hsindongyang/face_service.dart';
import 'package:hsindongyang/image_select_item.dart';
import 'package:hsindongyang/image_selection.dart';
import 'package:hsindongyang/photo_api.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageSelectPage extends StatefulWidget {
  const ImageSelectPage({super.key});

  @override
  State<ImageSelectPage> createState() => _ImageSelectPageState();
}

class _ImageSelectPageState extends State<ImageSelectPage> {
  Future<void> saveSelectedImages(List<String> imageIds, DateTime fetchTime,
      ImageSelection selection) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'images-${DateFormat("yyyy/MM/dd").format(fetchTime)}', imageIds);
    selection.clear();
  }

  String? selected_person;

  @override
  Widget build(BuildContext context) {
    PhotoApi api = context.watch<PhotoApi>();
    ImageSelection selection = context.watch<ImageSelection>();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          TextButton(
            child: const Text("Load"),
            onPressed: () {
              Map<String, String> personId = {
                "yang": "f8679bd1-a8d7-4975-9202-9275dd714203",
                "dong": "6e7ebba3-c68e-440c-9434-fb1f1807755c"
              };
              api.prepareImage(personId[selected_person]);
            },
          ),
          TextButton(
            child: const Text("Next"),
            onPressed: () {
              saveSelectedImages(
                  selection.selectedItem
                      .map((e) => api.images.elementAt(e).id ?? "")
                      .toList(),
                  api.fetchDate,
                  selection);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EditContentPage(),
              ));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
                child: Text("請從 ${api.images.length} 張照片中選擇最多十張相片 (${0}/10)")),
            DropdownButton(
                value: selected_person,
                items: ['dong', 'yang']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (dynamic s) {
                  setState(() {
                    selected_person = s;
                  });
                }),
            Expanded(
              child: ListView(children: imageSelectItemsList(api)),
            ),
          ],
        ),
      ),
    );
  }

  List<ImageSelectItem> imageSelectItemsList(PhotoApi api) {
    List<ImageSelectItem> list = [];
    for (var i = 0; i < api.images.length; i++) {
      list.add(ImageSelectItem(index: i, src: "${api.images[i].baseUrl}=w364"));
    }
    return list;
  }
}
