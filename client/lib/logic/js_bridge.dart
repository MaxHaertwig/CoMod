import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_js/flutter_js.dart';

class JSBridge {
  static final JSBridge _shared = JSBridge._internal();
  static final _jsRuntime = getJavascriptRuntime();

  final Future<void> _ready;

  factory JSBridge() => _shared;

  JSBridge._internal()
      : _ready = rootBundle.loadString('assets/client.js').then((string) async {
          const missingDeclarations = '''
          const clearTimeout = () => {};
          const clearInterval = () => {};
          ''';
          final result =
              await _jsRuntime.evaluateAsync(missingDeclarations + string);
          if (result.isError) {
            throw Exception('Error initializing JS runtime: $result');
          }
        }) {
    _jsRuntime.onMessage('ConsoleLog', (args) {
      print('[js] ConsoleLog: $args');
    });
  }

  Future<void> loadModel(String xml) async {
    await _ready;
    final code = 'client.loadModel(`$xml`);';
    final result = await _jsRuntime.evaluateAsync(code);
    if (result.isError) {
      print('[js] $code completed with $result');
    } else {
      print('[js] loadModel(...) ✓');
    }
  }

  void insertElement(String? parentID, String id, String nodeName) {
    final parentIDArg = parentID != null ? '"$parentID"' : 'null';
    _evaluate('client.insertElement($parentIDArg, "$id", "$nodeName");');
  }

  void deleteElement(String id) => _evaluate('client.deleteElement("$id");');

  void updateAttribute(String id, String attribute, String value) =>
      _evaluate('client.updateAttribute("$id", "$attribute", "$value");');

  void _evaluate(String code) {
    final result = _jsRuntime.evaluate(code);
    if (result.isError) {
      print('[js] $code completed with $result');
    } else {
      print('[js] $code ✓');
    }
  }
}
