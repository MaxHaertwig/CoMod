import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_type_type.dart';
import 'package:flutter/material.dart';

enum TypeLinkSize { regular, small }

class TypeLink extends StatelessWidget {
  final UMLType type;
  final TypeLinkSize size;
  final bottomMargin;
  final VoidCallback onTap;

  TypeLink(this.type, this.size, this.bottomMargin, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Card(
          margin: EdgeInsets.only(top: 0, bottom: bottomMargin ? 2 : 0),
          elevation: 2,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: size == TypeLinkSize.regular ? 12 : 6,
                vertical: size == TypeLinkSize.regular ? 8 : 6),
            child: Text(type.name,
                style: TextStyle(
                    fontSize: size == TypeLinkSize.regular ? 14 : 10,
                    fontStyle: type.type == UMLTypeType.abstractClass
                        ? FontStyle.italic
                        : FontStyle.normal)),
          ),
        ),
        onTap: onTap,
      );
}
