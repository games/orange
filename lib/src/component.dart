// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;




abstract class Component {
  Node _target;
  
  void start();
  void update(GameTime time);
  
  void attached(Node target) {
    _target = target;
  }
  
  void detached(Node target) {
    _target = null;
  }
}
