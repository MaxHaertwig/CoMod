import 'package:flutter/material.dart';

typedef ButtonPressedFunction = void Function(int);

class NoDataView extends StatelessWidget {
  final String title;
  final String message;
  final List<String> buttonLabels;
  final ButtonPressedFunction onButtonPressed;

  NoDataView(this.title, this.message, this.buttonLabels, this.onButtonPressed);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: buttonLabels
                  .asMap()
                  .entries
                  .map((entry) => ElevatedButton(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () => onButtonPressed(entry.key),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
}
