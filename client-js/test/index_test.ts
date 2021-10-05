import * as assert from 'assert';
import { Base64 } from 'js-base64';
import * as yjs from 'yjs';
import * as client from '../src/index';
import { createSampleYDoc } from './test_utils';

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
    assertChannels(['LocalUpdate', 'ModelSerialized', 'ModelSerialized']); // modification + sync
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

    client.insertElement('P', -1, 'A3', 'attribute', 'address', [['visibility', 'protected'], ['type', 'string']], ['tag']);

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    assert.strictEqual(person.get(3).getAttribute('id'), 'A3');
    assertChannels(['LocalUpdate', 'ModelSerialized']);
  });

  it('deletes elements', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    client.deleteElements(['PA2']);

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    assert.strictEqual((model.get(0) as yjs.XmlElement).get(1).length, 1);
    assertChannels(['LocalUpdate', 'ModelSerialized']);
  });

  it('updates text', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    client.updateText('PA1', 0, 1, 'fullN');

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    const personName = (person.get(1) as yjs.XmlElement).get(0) as yjs.XmlElement;
    assert.strictEqual(personName.get(0).toString(), 'fullName');
    assertChannels(['LocalUpdate', 'ModelSerialized']);
  });

  it('updates attributes', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    client.updateAttribute('P', 'test', 'a');

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    assert.strictEqual(person.getAttribute('test'), 'a');
    assertChannels(['LocalUpdate', 'ModelSerialized']);
  });

  it('moves elements', () => {
    const localDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(localDoc)), false);

    client.moveElement('PA2', client.MoveType.Up);

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const person = model.get(0) as yjs.XmlElement;
    assert.strictEqual((person.get(1) as yjs.XmlElement).get(0).getAttribute('id'), 'PA2');
    assertChannels(['LocalUpdate', 'ModelSerialized']);
  });

  it('observes remote changes', () => {
    const yDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(yDoc)), false);
    client.startObservingRemoteChanges();

    const serverDoc = new yjs.Doc();
    yjs.applyUpdate(serverDoc, yjs.encodeStateAsUpdate(yDoc));
    const person = (serverDoc.getXmlFragment().get(0) as yjs.XmlElement).get(0) as yjs.XmlElement;
    const personAttributes = person.get(1) as yjs.XmlElement;

    // Modify name element
    const personNameText = (personAttributes.get(0) as yjs.XmlElement).get(0) as yjs.XmlText;
    personNameText.delete(0, 1); // name -> ame
    personNameText.insert(0, 'fullN'); // ame -> fullName

    // Add 2 attributes
    person.setAttribute('key1', 'value1');
    person.setAttribute('key2', 'value2');

    // Add 2 elements
    const address = new yjs.XmlElement('attribute');
    address.setAttribute('id', 'PA3');
    address.setAttribute('visibility', 'protected');
    address.setAttribute('type', 'string');
    address.push([new yjs.XmlText('address')]);
    personAttributes.push([address]);

    const op = new yjs.XmlElement('operation');
    op.setAttribute('id', 'PO1');
    op.setAttribute('visibility', 'private');
    op.setAttribute('returnType', 'string');
    op.push([new yjs.XmlText('op')]);
    (person.get(2) as yjs.XmlElement).push([op]);

    // Remove age element
    personAttributes.delete(1);
    
    yjs.applyUpdate(client.activeDoc, yjs.encodeStateAsUpdate(serverDoc, yjs.encodeStateVector(yDoc)));

    const changes = JSON.parse(messages.find(msg => msg.channel === 'RemoteUpdate')!.message);
    assert.strictEqual(changes['text'].length, 1);
    assert.strictEqual(changes['elements'].length, 1);

    assert.deepEqual(changes['text'][0], ['PA1', 'fullName']);

    const personElementChanges = changes['elements'][0];
    assert.strictEqual(personElementChanges[0], 'P');
    assert.deepEqual(personElementChanges[1], [['key1', 'value1'], ['key2', 'value2']]);
    assert.deepEqual(personElementChanges[2], [
      ['<attribute id="PA3" type="string" visibility="protected">address</attribute>', 1],
      ['<operation id="PO1" returnType="string" visibility="private">op</operation>', 0]
    ]);
    assert.deepEqual(personElementChanges[3], [['PA2', 'attribute']]);
  });

  it('ignores local modifications when observing remote changes', () => {
    const yDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(yDoc)), false);
    client.startObservingRemoteChanges();
    
    client.updateAttribute('P', 'key', 'value');

    assertChannels(['LocalUpdate', 'ModelSerialized']);
  });

  it('does not duplicate concurrently moved elements', () => {
    const yDoc = createSampleYDoc();
    client.loadModel('uuid', Base64.fromUint8Array(yjs.encodeStateAsUpdate(yDoc)), false);
    client.startObservingRemoteChanges();

    client.moveElement('PA2', client.MoveType.Up);

    const serverDoc = new yjs.Doc();
    yjs.applyUpdate(serverDoc, yjs.encodeStateAsUpdate(yDoc));
    const serverPerson = (serverDoc.getXmlFragment().get(0) as yjs.XmlElement).get(0) as yjs.XmlElement;
    const serverPersonAttributes = serverPerson.get(1) as yjs.XmlElement;
    const serverPersonAge = serverPersonAttributes.get(1).clone() as yjs.XmlElement;
    serverDoc.transact(() => {
      serverPersonAttributes.delete(1);
      serverPersonAttributes.insert(0, [serverPersonAge]);
    });

    yjs.applyUpdate(client.activeDoc, yjs.encodeStateAsUpdate(serverDoc, yjs.encodeStateVector(yDoc)));

    const model = client.activeDoc.getXmlFragment().get(0) as yjs.XmlElement;
    const localPerson = model.get(0) as yjs.XmlElement;
    assert.strictEqual(localPerson.toArray().length, 3);
  });
});
