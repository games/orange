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
