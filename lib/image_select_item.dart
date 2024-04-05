import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:hsindongyang/image_selection.dart';
import 'package:provider/provider.dart';

class ImageSelectItem extends StatelessWidget {
  const ImageSelectItem({
    super.key,
    required this.index,
    required this.src,
  });
  final int index;
  final String src;

  @override
  Widget build(BuildContext context) {
    ImageSelection selection = context.watch<ImageSelection>();
    int? selectedIndex = selection.itemSelectedIndex[index];

    return badges.Badge(
      badgeStyle: const badges.BadgeStyle(
        badgeColor: Colors.blue,
        padding: EdgeInsets.all(10),
      ),
      badgeContent: Text(
        selectedIndex != null ? selectedIndex.toString() : '',
        style: const TextStyle(color: Colors.white),
      ),
      showBadge: selectedIndex != null,
      position: badges.BadgePosition.topStart(top: 7, start: 7),
      child: GestureDetector(
        onTap: () {
          selection.toggleItem(index);
        },
        child: Image.network(
          src,
        ),
      ),
    );
  }
}
