import * as yjs from 'yjs';

export function createSampleYDoc(): yjs.Doc {
  const yDoc = new yjs.Doc();
    
  const model = new yjs.XmlElement('model');
  model.setAttribute('uuid', 'uuid');
  yDoc.getXmlFragment().push([model]);
  
  const person = new yjs.XmlElement('class');
  person.setAttribute('id', 'P');
  person.push([new yjs.XmlText('Person')]);
  model.push([person]);
    
  const name = new yjs.XmlElement('attribute');
  name.setAttribute('id', 'PA1');
  name.setAttribute('visibility', 'public');
  name.setAttribute('type', 'string');
  name.push([new yjs.XmlText('name')]);
  person.push([name]);
  
  const age = new yjs.XmlElement('attribute');
  age.setAttribute('id', 'PA2');
  age.setAttribute('visibility', 'private');
  age.setAttribute('type', 'integer');
  age.push([new yjs.XmlText('age')]);
  person.push([age]);
  
  return yDoc;
}
