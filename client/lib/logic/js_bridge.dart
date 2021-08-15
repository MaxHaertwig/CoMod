import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:client/logic/models_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_js/flutter_js.dart';
import 'package:tuple/tuple.dart';

class JSBridge {
  static final JSBridge _shared = JSBridge._internal();
  static final _jsRuntime = getJavascriptRuntime();

  final Future<void> _ready;

  String? _loadedModelXml;

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
    _setupChannels();
  }

  void _setupChannels() {
    _jsRuntime.onMessage('ModelLoaded', (args) {
      _loadedModelXml = args;
    });
    _jsRuntime.onMessage('ModelSerialized', (args) {
      ModelsManager.saveModel(args['uuid'], base64Decode(args['data']));
    });
    _jsRuntime.onMessage('DocUpdate', (args) => print('[js] DocUpdate: $args'));
  }

  Future<void> newModel(String uuid) async {
    await _ready;
    await _evaluate('client.newModel("$uuid");');
  }

  Future<String> loadModel(String uuid, Uint8List data) async {
    await _ready;
    final code = 'client.loadModel("$uuid", "${base64Encode(data)}");';
    final result = await _jsRuntime.evaluateAsync(code);
    if (!kReleaseMode) {
      if (result.isError) {
        print('[js] $code completed with $result');
      } else {
        print('[js] loadModel(...) ✓');
      }
    }
    return _loadedModelXml!;
  }

  void insertElement(
      String parentID,
      String id,
      String nodeName,
      bool hasNameElement,
      String name,
      List<Tuple2<String, String>>? attributes) {
    final hasNameElementString = hasNameElement ? 'true' : 'false';
    final attributesString = attributes != null
        ? ', [${attributes.map((tuple) => '["${tuple.item1}", "${tuple.item2}"]').join(',')}]'
        : '';
    _evaluate(
        'client.insertElement("$parentID", "$id", "$nodeName", "$name", "$hasNameElementString"$attributesString);');
  }

  void deleteElement(String id) => _evaluate('client.deleteElement("$id");');

  // TODO: apply delta
  void updateText(String id, String oldText, String newText) =>
      _evaluate('client.updateText("$id", "$newText");');

  void updateAttribute(String id, String attribute, String value) =>
      _evaluate('client.updateAttribute("$id", "$attribute", "$value");');

  Future<void> _evaluate(String code) async {
    final result = await _jsRuntime.evaluateAsync(code);
    if (!kReleaseMode) {
      if (result.isError) {
        print('[js] $code completed with $result');
      } else {
        print('[js] $code ✓');
      }
    }
  }
}
