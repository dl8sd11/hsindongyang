import 'package:flutter/material.dart';

class ImageSelection extends ChangeNotifier {
// private
  final List<int> selectedItem = [];

  void _insert(int index) {
    selectedItem.add(index);
    itemSelectedIndex[index] = selectedItem.length;
  }

  void _delete(int index) {
    int position = selectedItem.indexOf(index);
    selectedItem.skip(position + 1).forEach((element) {
      itemSelectedIndex[element] = itemSelectedIndex[element]! - 1;
    });
    selectedItem.remove(index);
    itemSelectedIndex.remove(index);
  }

// public
  Map<int, int> itemSelectedIndex = {};

  void clear() {
    selectedItem.clear();
    itemSelectedIndex.clear();
  }

  void toggleItem(int index) {
    if (itemSelectedIndex.containsKey(index)) {
      _delete(index);
    } else {
      _insert(index);
    }
    notifyListeners();
  }
}
