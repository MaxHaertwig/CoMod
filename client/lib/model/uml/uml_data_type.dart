import 'package:client/extensions.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

enum UMLPrimitiveType { voidType, boolean, integer, real, string }

extension UMLPrimitiveTypeExt on UMLPrimitiveType {
  static UMLPrimitiveType? fromString(String string) {
    return string == 'void'
        ? UMLPrimitiveType.voidType
        : UMLPrimitiveType.values
            .firstWhereOrNull((value) => describeEnum(value) == string);
  }
}

class UMLDataType {
  Either<UMLPrimitiveType, String> type;

  UMLDataType(this.type);

  UMLDataType.voidType() : this(Left(UMLPrimitiveType.voidType));
  UMLDataType.boolean() : this(Left(UMLPrimitiveType.boolean));
  UMLDataType.integer() : this(Left(UMLPrimitiveType.integer));
  UMLDataType.real() : this(Left(UMLPrimitiveType.real));
  UMLDataType.string() : this(Left(UMLPrimitiveType.string));
  UMLDataType.object(String id) : this(Right(id));

  static UMLDataType fromString(String string) {
    var primitiveType = UMLPrimitiveTypeExt.fromString(string);
    return UMLDataType(
        primitiveType != null ? Left(primitiveType) : Right(string));
  }

  String get stringRepresentation => type.isLeft
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
  bool operator ==(other) {
    if (!(other is UMLDataType) || type.isLeft != other.type.isLeft) {
      return false;
    }
    return type.isLeft
        ? type.left == other.type.left
        : type.right == other.type.right;
  }
}
