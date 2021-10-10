import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

enum UMLPrimitiveType { voidType, boolean, integer, real, string }

extension UMLPrimitiveTypeExt on UMLPrimitiveType {
  static UMLPrimitiveType? fromString(String string) => string == 'void'
      ? UMLPrimitiveType.voidType
      : UMLPrimitiveType.values
          .firstWhereOrNull((value) => describeEnum(value) == string);
}

class UMLDataType {
  final Either<UMLPrimitiveType, String> type;

  const UMLDataType(this.type);

  const UMLDataType.voidType() : this(const Left(UMLPrimitiveType.voidType));
  const UMLDataType.boolean() : this(const Left(UMLPrimitiveType.boolean));
  const UMLDataType.integer() : this(const Left(UMLPrimitiveType.integer));
  const UMLDataType.real() : this(const Left(UMLPrimitiveType.real));
  const UMLDataType.string() : this(const Left(UMLPrimitiveType.string));
  UMLDataType.type(String id) : this(Right(id));

  static UnmodifiableListView<UMLDataType> primitiveDataTypes(
          bool includingVoid) =>
      UnmodifiableListView(includingVoid
          ? UMLPrimitiveType.values.map((pt) => UMLDataType(Left(pt)))
          : UMLPrimitiveType.values
              .where((pt) => pt != UMLPrimitiveType.voidType)
              .map((pt) => UMLDataType(Left(pt))));

  static UMLDataType fromString(String string) {
    final primitiveType = UMLPrimitiveTypeExt.fromString(string);
    return UMLDataType(
        primitiveType != null ? Left(primitiveType) : Right(string));
  }

  String stringRepresentation(UMLModel umlModel) => type.isLeft
      ? xmlRepresentation
      : umlModel.types[type.right]?.name ?? '<error>'; // TODO: use string?

  String get xmlRepresentation => type.isLeft
      ? (type.left == UMLPrimitiveType.voidType
          ? 'void'
          : describeEnum(type.left))
      : type.right;

  @override
  String toString() =>
      type.isLeft ? type.left.toString() : type.right.toString();

  @override
  int get hashCode => type.hashCode;

  @override
  bool operator ==(other) =>
      other is UMLDataType &&
      type.isLeft == other.type.isLeft &&
      ((type.isLeft && type.left == other.type.left) ||
          (!type.isLeft && type.right == other.type.right));
}
