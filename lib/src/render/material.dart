// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


part of orange;


class Material {
  
  String name;
  Color color;
  bool wireframe = false;
  Texture mainTexture;
  Vector2 mainTextureOffset;
  Vector2 mainTextureScale;
  Shader shader;
  
}
