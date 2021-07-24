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

  static UMLDataType fromString(String string) {
    var primitiveType = UMLPrimitiveTypeExt.fromString(string);
    return UMLDataType(
        primitiveType != null ? Left(primitiveType) : Right(string));
  }

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
