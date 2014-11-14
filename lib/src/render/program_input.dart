// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;



class ProgramInput {
  String name;
  dynamic location;
  int type;

  ProgramInput(this.name, this.location, this.type);

  @override
  String toString() => "${name}: ${location}";
}

class ShaderSemantic {
  static const ShaderSemantic position = const ShaderSemantic(1);
  static const ShaderSemantic e2 = const ShaderSemantic(2);
  static const ShaderSemantic e3 = const ShaderSemantic(3);
  final int id;
  const ShaderSemantic(this.id);
}
