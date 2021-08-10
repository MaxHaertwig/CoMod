const assert = require('assert');

function assertStructure(element, expectation) {
  assert.equal(element.nodeName, expectation.nodeName);
  if (expectation.attributes) {
    assert.equal(Object.entries(element.getAttributes()).length, expectation.attributes.size);
    expectation.attributes.forEach((value, attribute) => assert.equal(element.getAttribute(attribute), value));
  }
  if (expectation.elements) {
    assert.equal(element.length, expectation.elements.length);
    expectation.elements.forEach((child, index) => {
      if (typeof (child) === 'string') {
        assert.equal(element.get(index).toString(), child);
      } else {
        assertStructure(element.get(index), child);
      }
    });
  }
}

describe('index_test.js', () => {
  const { xmlToYjs } = require('../src/index');

  it('should convert an XML structure to a yjs tree', () => {
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
      <model version="1.0" uuid="M">
        <class id="P" x="0" y="0">
          <name>Person</name>
          <attribute id="PA1" visibility="public" type="string">name</attribute>
          <attribute id="PA2" visibility="private" type="integer">age</attribute>
        </class>
        <class id="S" x="0" y="100">
          <name>Student</name>
          <attribute id="SA1" visibility="public" type="string">major</attribute>
          <operation id="SO1" visibility="protected" returnType="void">
            <name>study</name>
            <param id="SOP1" type="string">subject</param>
            <param id="SOP2" type="integer">hours</param>
          </operation>
        </class>
      </model>
      `;

    const classes = xmlToYjs(xml).getXmlFragment('uml');
    assert.equal(classes.length, 2);

    assertStructure(classes.get(0), {
      nodeName: 'class',
      attributes: new Map([['id', 'P'], ['x', '0'], ['y', '0']]),
      elements: [
        'Person',
        {
          nodeName: 'attribute',
          attributes: new Map([['id', 'PA1'], ['visibility', 'public'], ['type', 'string']]),
          elements: ['name']
        },
        {
          nodeName: 'attribute',
          attributes: new Map([['id', 'PA2'], ['visibility', 'private'], ['type', 'integer']]),
          elements: ['age']
        }
      ]
    });
    assertStructure(classes.get(1), {
      nodeName: 'class',
      attributes: new Map([['id', 'S'], ['x', '0'], ['y', '100']]),
      elements: [
        'Student',
        {
          nodeName: 'attribute',
          attributes: new Map([['id', 'SA1'], ['visibility', 'public'], ['type', 'string']]),
          elements: ['major']
        },
        {
          nodeName: 'operation',
          attributes: new Map([['id', 'SO1'], ['visibility', 'protected'], ['returnType', 'void']]),
          elements: [
            'study',
            {
              nodeName: 'param',
              attributes: new Map([['id', 'SOP1'], ['type', 'string']])
            },
            {
              nodeName: 'param',
              attributes: new Map([['id', 'SOP2'], ['type', 'integer']])
            }
          ]
        }
      ]
    });
  });
});
