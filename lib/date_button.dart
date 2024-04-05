import 'package:flutter/material.dart';

class DateButton extends StatelessWidget {
  const DateButton({
    super.key,
    required this.label,
    required this.date,
    required this.buttonText,
    required this.onPress,
  });
  final String label;
  final String date;
  final String buttonText;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('$label：'),
        ),
        GestureDetector(
          onTap: onPress,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: onPress, child: Text(buttonText))
            ],
          ),
        ),
      ],
    );
  }
}
