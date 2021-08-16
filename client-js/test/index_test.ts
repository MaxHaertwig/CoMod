import * as assert from 'assert';
import { Base64 } from 'js-base64';
import * as yjs from 'yjs';
import * as client from '../src/index';
import {createSampleYDoc} from './test_utils';

interface Message {
  channel: string;
  message: string;
}

describe('client-js', () => {
  let messages: Message[];
  (global as any).sendMessage = (channel: string, message: string) => {
    messages.push({ channel, message });
  };

  function assertChannels(expected: string[]) {
    assert.strictEqual(messages.length, expected.length);
    for (let i = 0; i < messages.length; i++) {
      assert.strictEqual(messages[i].channel, expected[i]);
    }
  }

  beforeEach(() => {
    messages = [];
  });

  it('creates new models', () => {
    client.newModel('uuid');
    assertChannels(['ModelSerialized']);
  });

  it('loads models (without serialization)', () => {
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(createSampleYDoc())), false);
    assert.strictEqual(messages.length, 0);
  });

  it('loads models (with serialization)', () => {
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(createSampleYDoc())), true);
    assertChannels(['ModelSerialized']);
  });

  it('provides state vectors', () => {
    const yDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(yDoc)), false);
    assert.strictEqual(client.stateVector(), Base64.fromUint8Array(yjs.encodeStateVector(yDoc)));
    assert.strictEqual(messages.length, 0);
  });

  it('syncs empty server updates', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);
    client.sync(undefined, undefined);
    assert.strictEqual(messages.length, 0);
  });

  it('syncs server updates', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    const serverDoc = new yjs.Doc();
    yjs.applyUpdate(serverDoc, yjs.encodeStateAsUpdate(localDoc));

    client.updateAttribute('P', 'a1', 'localChange');
    const model = serverDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    person.setAttribute('a2', 'remoteChange');
    
    const update = client.sync(
      Base64.fromUint8Array(yjs.encodeStateVector(serverDoc)),
      Base64.fromUint8Array(yjs.encodeStateAsUpdate(serverDoc, Base64.toUint8Array(client.stateVector())))
    )!;
    yjs.applyUpdate(serverDoc, Base64.toUint8Array(update));
    
    assert.strictEqual(person.getAttribute('a1'), 'localChange');
    assertChannels(['DocUpdate', 'ModelSerialized', 'ModelSerialized']); // modification + sync
  });

  it('processes updates', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);
    
    const serverDoc = new yjs.Doc();
    yjs.applyUpdate(serverDoc, yjs.encodeStateAsUpdate(localDoc));
    const model = serverDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    person.setAttribute('a2', 'remoteChange');

    client.processUpdate(Base64.fromUint8Array(yjs.encodeStateAsUpdate(serverDoc, Base64.toUint8Array(client.stateVector()))));
    assertChannels(['ModelSerialized']);
  });

  it('inserts elements', () => {
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(createSampleYDoc())), false);

    client.insertElement('P', 'A3', 'attribute', false, 'address', [['visibility', 'protected'], ['type', 'string']]);

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    assert.strictEqual(person.get(3).getAttribute('id'), 'A3');
    assertChannels(['DocUpdate', 'ModelSerialized']);
  });

  it('deletes elements', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    client.deleteElement('PA2');

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    assert.strictEqual(model.get(0).length, 2); // name + attribute
    assertChannels(['DocUpdate', 'ModelSerialized']);
  });

  it('updates text', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    client.updateText('PA1', 'fullName');

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    const personName = person.get(1) as yjs.XmlElement;
    assert.strictEqual(personName.get(0).toString(), 'fullName');
    assertChannels(['DocUpdate', 'ModelSerialized']);
  });

  it('updates attributes', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    client.updateAttribute('P', 'test', 'a');

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    assert.strictEqual(person.getAttribute('test'), 'a');
    assertChannels(['DocUpdate', 'ModelSerialized']);
  });
});
