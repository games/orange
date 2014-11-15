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
class RingGenerator {

  static Mesh create(double innerRadius, double outerRadius, {filters: null, segments: 64, thetaStart: 0.0,
      thetaLength: PI2, stripTextureCoordinates: true}) {

    var vertices = [];
    var texCoords = [];
    var indices = [];

    // vertices
    Vector3 v = new Vector3.zero();
    
    for (int i = 0; i <= segments; i++) {
      double percent = i / segments;
      v.x = innerRadius * Math.cos(thetaStart + percent * thetaLength);
      v.z = innerRadius * Math.sin(thetaStart + percent * thetaLength);
      vertices.addAll([v.x, v.y, v.z]);

      v.x = outerRadius * Math.cos(thetaStart + percent * thetaLength);
      v.z = outerRadius * Math.sin(thetaStart + percent * thetaLength);
      vertices.addAll([v.x, v.y, v.z]);
    }

    // tex coords
    if (stripTextureCoordinates) {
      Vector2 v = new Vector2.zero();
      int index = 0;
      for (int i = 0; i <= segments; i++) {
        double percent = i / segments;
        v.x = 0.0;
        v.y = percent;
        texCoords.addAll([v.x, v.y]);

        index++;
        v.x = 1.0;
        v.y = percent;
        texCoords.addAll([v.x, v.y]);
        index++;
      }
    } else {
      Vector2 v = new Vector2.zero();
      int index = 0;
      for (int i = 0; i <= segments; i++) {
        var px = vertices[index * 3];
        var pz = vertices[index * 3 + 2];

        double x = (px / (outerRadius + 1.0)) * 0.5;
        double y = (pz / (outerRadius + 1.0)) * 0.5;
        v.x = x + 0.5;
        v.y = y + 0.5;
        texCoords.addAll([v.x, v.y]);
        index++;

        px = vertices[index * 3];
        pz = vertices[index * 3 + 2];
        x = (px / (outerRadius + 1.0)) * 0.5;
        y = (pz / (outerRadius + 1.0)) * 0.5;
        v.x = x + 0.5;
        v.y = y + 0.5;
        texCoords.addAll([v.x, v.y]);
        index++;
      }
    }

    // indices
    int length = segments * 2;
    for (int i = 0; i < length; i += 2) {
      indices.add(i + 0);
      indices.add(i + 1);
      indices.add(i + 3);
      indices.add(i + 0);
      indices.add(i + 3);
      indices.add(i + 2);
    }

    var mesh = new Mesh();
    mesh.vertices = vertices;
    mesh.texCoords = texCoords;
    mesh.indices = indices;
    mesh.computeNormals();
    return mesh;

  }

}
