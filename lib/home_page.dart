import 'package:flutter/material.dart';
import 'package:hsindongyang/date_button.dart';
import 'package:hsindongyang/image_select_page.dart';
import 'package:hsindongyang/photo_api.dart';
import 'package:hsindongyang/post_page.dart';
import 'package:hsindongyang/setting_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PhotoApi api = context.watch<PhotoApi>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('東徉發文機'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingPage(),
                ));
              },
            ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DateButton(
                date: DateFormat('yyyy/MM/dd').format(api.fetchDate),
                buttonText: "寫",
                label: "寫文日期",
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ImageSelectPage(),
                  ));
                },
              ),
              const SizedBox(height: 20),
              DateButton(
                date: DateFormat('yyyy/MM/dd').format(api.postDate),
                buttonText: "發",
                label: "發文日期",
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PostPage(),
                  ));
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ));
  }
}
