import 'package:flutter/material.dart';

typedef OnJoinSessionFunction = void Function(String);

// TODO: support model prefix (first 8 characters)
class JoinCollaborationSessionDialog extends StatefulWidget {
  final OnJoinSessionFunction onJoinSession;

  JoinCollaborationSessionDialog({required this.onJoinSession});

  @override
  State<StatefulWidget> createState() => _JoinCollaborationSessionDialogState();
}

class _JoinCollaborationSessionDialogState
    extends State<JoinCollaborationSessionDialog> {
  static const _uuidRegex =
      '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';
  static final _uuidRegExp = RegExp('\\b$_uuidRegex\\b', caseSensitive: false);
  static final _linkRegExp = RegExp(
    '\\bconnect://maxhaertwig.com/thesis/$_uuidRegex\\b',
    caseSensitive: false,
  );

  final _textEditingController = TextEditingController();

  var _isJoinButtonEnabled = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Collaborate'),
        content: TextField(
          autofocus: true,
          autocorrect: false,
          decoration:
              const InputDecoration(hintText: 'Enter link or session ID'),
          controller: _textEditingController,
          onChanged: (value) {
            final trimmedValue = value.trim();
            setState(() => _isJoinButtonEnabled =
                _uuidRegExp.allMatches(trimmedValue).isNotEmpty ||
                    _linkRegExp.allMatches(trimmedValue).isNotEmpty);
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Join',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _isJoinButtonEnabled
                ? () {
                    final trimmedText = _textEditingController.text.trim();
                    final uuid = trimmedText.startsWith('collaboration://')
                        ? trimmedText.split('/').last
                        : trimmedText;
                    widget.onJoinSession(uuid);
                    Navigator.pop(context);
                  }
                : null,
          ),
        ],
      );
}
