import 'package:flutter/material.dart';

class NoDataView extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final Function() onButtonPressed;

  NoDataView(this.title, this.message, this.buttonText, this.onButtonPressed);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
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
          ElevatedButton(
            child: Text(buttonText, style: const TextStyle(fontSize: 18)),
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}
