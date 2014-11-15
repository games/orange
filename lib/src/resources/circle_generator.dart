/*
  Orange : Simplified BSD License

  Copyright (c) 2014, Valor Zhong
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
  following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
     disclaimer.
    
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
     following disclaimer in the documentation and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
 */


part of orange;

/// from https://github.com/johnmccutchan/vector_math/tree/master/lib/src/vector_math_geometry/generators
/// thanks John McCutchan
class CircleGenerator {

  static Mesh create(double radius, {segments: 64, thetaStart: 0.0, thetaLength: PI2}) {
    var vertices = [],
        indices = [],
        texCoords = [];

    var v = new Vector3.zero();
    vertices.addAll([0.0, 0.0, 0.0]);
    
    for (int i = 0; i <= segments; i++) {
      double percent = i / segments;
      v.x = radius * Math.cos(thetaStart + percent * thetaLength);
      v.z = radius * Math.sin(thetaStart + percent * thetaLength);
      vertices.addAll([v.x, v.y, v.z]);
    }

    var v2 = new Vector2(0.5, 0.5);
    texCoords.addAll([0.5, 0.5]);
    int index = 1;
    for (int i = 0; i <= segments; i++) {
      var px = vertices[index * 3];
      var py = vertices[index * 3 + 1];
      var pz = vertices[index * 3 + 2];
      double x = (px / (radius + 1.0)) * 0.5;
      double y = (pz / (radius + 1.0)) * 0.5;
      v2.x = x + 0.5;
      v2.y = y + 0.5;
      texCoords.addAll([v2.x, v2.y]);
      index++;
    }

    for (int i = 1; i <= segments; i++) {
      indices.addAll([i, i + 1, 0]);
    }

    var mesh = new Mesh();
    mesh.vertices = vertices;
    mesh.texCoords = texCoords;
    mesh.indices = indices;
    mesh.computeNormals();
    return mesh;
  }

}
