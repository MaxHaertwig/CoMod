import * as yjs from 'yjs';

export function createSampleYDoc(): yjs.Doc {
  const yDoc = new yjs.Doc();
    
  const model = new yjs.XmlElement('model');
  model.setAttribute('uuid', 'uuid');
  yDoc.getXmlFragment().push([model]);
  
  const person = new yjs.XmlElement('class');
  person.setAttribute('id', 'P');
  person.push([new yjs.XmlText('Person'), new yjs.XmlElement('attributes'), new yjs.XmlElement('operations')]);
  model.push([person]);
    
  const name = new yjs.XmlElement('attribute');
  name.setAttribute('id', 'PA1');
  name.setAttribute('visibility', 'public');
  name.setAttribute('type', 'string');
  name.push([new yjs.XmlText('name')]);
  (person.get(1) as yjs.XmlElement).push([name]);
  
  const age = new yjs.XmlElement('attribute');
  age.setAttribute('id', 'PA2');
  age.setAttribute('visibility', 'private');
  age.setAttribute('type', 'integer');
  age.push([new yjs.XmlText('age')]);
  (person.get(1) as yjs.XmlElement).push([age]);

  const study = new yjs.XmlElement('operation');
  study.setAttribute('id', 'PO1');
  study.setAttribute('visibility', 'protected');
  study.setAttribute('returnType', 'void');
  study.push([new yjs.XmlText('study')]);
  (person.get(2) as yjs.XmlElement).push([study]);

  const studyParam1 = new yjs.XmlElement('param');
  studyParam1.setAttribute('id', 'PO1P1');
  studyParam1.setAttribute('type', 'string');
  studyParam1.push([new yjs.XmlText('subject')]);
  study.push([studyParam1]);

  const studyParam2 = new yjs.XmlElement('param');
  studyParam2.setAttribute('id', 'PO1P2');
  studyParam2.setAttribute('type', 'integer');
  studyParam2.push([new yjs.XmlText('hours')]);
  study.push([studyParam2]);
  
  return yDoc;
}
