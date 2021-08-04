import 'package:flutter/material.dart';

class MenuItem<T> extends PopupMenuItem<T> {
  final IconData icon;
  final String title;
  final T value;
  final bool isDestructive;

  MenuItem(this.icon, this.title, this.value, {this.isDestructive = false})
      : super(
          value: value,
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.red : null),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: isDestructive ? Colors.red : null),
              )
            ],
          ),
        );
}
