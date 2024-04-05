import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/photoslibrary/v1.dart';
import 'package:hsindongyang/photo_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  DateTime selectedDate = DateTime.now();
  Album? selectedAlbum;
  String? savedAlbumId;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveSettings(PhotoApi api) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('albumId', selectedAlbum?.id ?? "");
    await prefs.setString('next-edit-date', selectedDate.toString());
    await prefs.setString('next-post-date', selectedDate.toString());
    api.fetchDate = selectedDate;
    api.postDate = selectedDate;
    api.notifyListeners();
  }

  Future<void> deleteData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateString =
        prefs.getString('next-edit-date') ?? DateTime.now().toString();
    setState(() {
      selectedDate = DateTime.parse(startDateString);
      savedAlbumId = prefs.getString('albumId');
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    PhotoApi api = context.watch<PhotoApi>();
    final GoogleSignInAccount? user = api.currentUser;
    final albums = api.albums ?? [];

    final initAlbum = albums.firstWhere((value) => value.id == savedAlbumId,
        orElse: () => Album());

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          TextButton(
            child: const Text("Clear"),
            onPressed: () {
              deleteData();
            },
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              saveSettings(api);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: api.isSignedIn
          ? Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ListTile(
                            leading: GoogleUserCircleAvatar(
                              identity: user!,
                            ),
                            title: Text(user.displayName ?? ''),
                            subtitle: Text(user.email),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            api.signOut();
                          },
                          child: const Text("登出"))
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Align(
                      alignment: Alignment.centerLeft, child: Text("選擇相簿：")),
                  albums.isNotEmpty
                      ? DropdownMenu<Album>(
                          initialSelection: initAlbum,
                          onSelected: (value) {
                            setState(() {
                              selectedAlbum = value;
                            });
                          },
                          dropdownMenuEntries: albums
                              .map<DropdownMenuEntry<Album>>((Album value) {
                            return DropdownMenuEntry<Album>(
                                value: value, label: value.title ?? "unknown");
                          }).toList(),
                        )
                      : const Text("No album"),
                  const SizedBox(height: 30),
                  const Align(
                      alignment: Alignment.centerLeft, child: Text("開始日期：")),
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    child: Text("${selectedDate.toLocal()}".split(' ')[0]),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SignInButton(
                    Buttons.google,
                    onPressed: () {
                      api.signIn();
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
