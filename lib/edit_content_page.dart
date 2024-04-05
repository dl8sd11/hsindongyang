import 'package:flutter/material.dart';
import 'package:hsindongyang/photo_api.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditContentPage extends StatefulWidget {
  const EditContentPage({super.key});

  @override
  State<EditContentPage> createState() => _EditContentPageState();
}

class _EditContentPageState extends State<EditContentPage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<void> saveContent(DateTime fetchDate, PhotoApi api) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'content-${DateFormat("yyyy/MM/dd").format(fetchDate)}',
        myController.text);
    api.advanceFetchDate();
    await prefs.setString('next-edit-date', api.fetchDate.toString());
  }

  @override
  Widget build(BuildContext context) {
    PhotoApi api = context.watch<PhotoApi>();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              saveContent(api.fetchDate, api);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text("Content"),
            TextField(
              controller: myController,
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            )
          ],
        ),
      ),
    );
  }
}
