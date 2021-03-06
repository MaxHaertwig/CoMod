import 'dart:async';
import 'dart:convert';

import 'package:client/extensions.dart';
import 'package:client/logic/models_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_js/flutter_js.dart';
import 'package:tuple/tuple.dart';

typedef TextChange = Tuple2<String, String>; // (id, newText)
typedef ElementChange = Tuple4<
    String, // id
    List<Tuple2<String, String>>, // Updated attributes (attribute, newValue)
    List<Tuple2<String, int>>, // Inserted elements (xml, index)
    List<Tuple2<String, String>> // Deleted elements (id, tag)
    >;

typedef LocalUpdateFunction = void Function(List<int>);
typedef RemoteUpdateFunction = void Function(
    List<TextChange>, List<ElementChange>);

class JSBridge {
  static final JSBridge _shared = JSBridge._internal();
  static final _jsRuntime = getJavascriptRuntime();

  // Instrumentation for client test:
  // var measurements = <int>[];
  // var count = 0;

  LocalUpdateFunction? onLocalUpdate;
  RemoteUpdateFunction? onRemoteUpdate;

  List<String>? transactionStatements;

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
    _setupChannels();
  }

  void _setupChannels() {
    _jsRuntime.onMessage(
        'ModelSerialized',
        (args) =>
            ModelsManager.saveModel(args['uuid'], base64Decode(args['data'])));
    _jsRuntime.onMessage('LocalUpdate', (args) {
      print('[js] LocalUpdate: $args');
      if (onLocalUpdate != null) {
        onLocalUpdate!(base64Decode(args));
      }
    });
    _jsRuntime.onMessage('RemoteUpdate', (args) {
      print('[js] RemoteUpdate: $args');
      if (onRemoteUpdate != null) {
        final textChanges = args['text']
            .map<TextChange>((tc) => Tuple2(tc[0] as String, tc[1] as String))
            .toList() as List<TextChange>;
        final elementChanges = args['elements']
            .map<ElementChange>((ec) => Tuple4(
                  ec[0] as String,
                  ec[1]
                      .map<Tuple2<String, String>>(
                          (c) => Tuple2(c[0] as String, c[1] as String))
                      .toList() as List<Tuple2<String, String>>,
                  ec[2]
                      .map<Tuple2<String, int>>(
                          (c) => Tuple2(c[0] as String, c[1] as int))
                      .toList() as List<Tuple2<String, int>>,
                  ec[3]
                      .map<Tuple2<String, String>>(
                          (c) => Tuple2(c[0] as String, c[1] as String))
                      .toList() as List<Tuple2<String, String>>,
                ))
            .toList() as List<ElementChange>;
        try {
          onRemoteUpdate!(textChanges, elementChanges);
        } catch (error) {
          print(error);
        }
      }
    });
  }

  Future<void> newModel(String uuid) async {
    await _ready;
    await _evaluate('client.newModel("$uuid");');
  }

  Future<String> loadModel(
      String uuid, List<int> data, bool shouldSerialize) async {
    await _ready;
    final shouldSerializeString = shouldSerialize ? 'true' : 'false';
    final code =
        'client.loadModel("$uuid", "${base64Encode(data)}", $shouldSerializeString)';
    final xml = await _evaluate(code);
    return xml
        .substring(1, xml.length - 1) // Remove leading and trailing quotes
        .replaceAll('\\"', '"'); // Replace escaped quotes
  }

  Future<List<int>> stateVector() async =>
      base64Decode(await _evaluate('client.stateVector()'));

  Future<List<int>?> sync(
      List<int> serverStateVector, List<int> serverUpdate) async {
    final serverStateVectorString = serverStateVector.isEmpty
        ? 'undefined'
        : '"${base64Encode(serverStateVector)}"';
    final serverUpdateString =
        serverUpdate.isEmpty ? 'undefined' : '"${base64Encode(serverUpdate)}"';
    final result = await _evaluate(
        'client.sync($serverStateVectorString, $serverUpdateString)');
    return result.isEmpty ? null : base64Decode(result);
  }

  void processUpdate(List<int> data) {
    // Instrumentation for client test:
    // var s = Stopwatch()..start();
    _evaluate('client.processUpdate("${base64Encode(data)}");');
    // s.stop();
    // count += 1;
    // measurements.add(s.elapsedMilliseconds);
    // if (measurements.length % 10 == 0) {
    //   print('$count: ${measurements.reduce((a, b) => a + b) / 10}');
    //   measurements.removeAt(0);
    // }
  }

  void beginTransaction() {
    assert(transactionStatements == null);
    transactionStatements = [];
  }

  void endTransaction() {
    assert(transactionStatements != null);
    if (transactionStatements!.isNotEmpty) {
      if (transactionStatements!.length == 1) {
        _evaluate(transactionStatements![0]);
      } else {
        _evaluate('''client.beginTransaction();
        client.activeDoc.transact(() => {
          ${transactionStatements!.join('')}
        });
        client.endTransaction();''');
      }
    }
    transactionStatements = null;
  }

  void insertElement(
      String parentID,
      int parentTagIndex,
      String id,
      String nodeName,
      String name,
      List<Tuple2<String, String>>? attributes,
      List<String>? tags) {
    final attributesString = attributes != null
        ? '[${attributes.map((tuple) => '["${tuple.item1}", "${tuple.item2}"]').join(', ')}]'
        : 'undefined';
    final tagsString = tags != null
        ? '[${tags.map((tag) => '"$tag"').join(', ')}]'
        : 'undefined';
    _evaluateWithTransaction(
        'client.insertElement("$parentID", $parentTagIndex, "$id", "$nodeName", "$name", $attributesString, $tagsString);');
  }

  void deleteElements(List<String> ids) => _evaluateWithTransaction(
      'client.deleteElements([${ids.map((id) => '"$id"').join(', ')}]);');

  void updateText(
          String id, int position, int deleteLength, String insertString) =>
      _evaluateWithTransaction(
          'client.updateText("$id", $position, $deleteLength, "$insertString");');

  void updateAttribute(String id, String attribute, String value) =>
      _evaluateWithTransaction(
          'client.updateAttribute("$id", "$attribute", "$value");');

  void moveElement(String id, MoveType moveType) =>
      _evaluate('client.moveElement("$id", ${moveType.index});');

  void startObservingRemoteChanges() =>
      _evaluate('client.startObservingRemoteChanges();');

  void stopObservingRemoteChanges() =>
      _evaluate('client.stopObservingRemoteChanges();');

  void _evaluateWithTransaction(String code) {
    if (transactionStatements != null) {
      transactionStatements!.add(code);
    } else {
      _evaluate(code);
    }
  }

  Future<String> _evaluate(String code) async {
    final result = await _jsRuntime.evaluateAsync(code);
    if (!kReleaseMode) {
      if (result.isError) {
        print('[js] $code completed with $result');
      } else {
        print('[js] $code ???');
      }
    }
    return result.stringResult;
  }
}
