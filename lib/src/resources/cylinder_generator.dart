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



class CylinderGenerator {

  static Mesh create({num topRadius: 1, num bottomRadius: 1, num height: 2, int capSegments: 50, int heightSegments:
      1}) {

    var vertices = [];
    var texCoords = [];
    var indices = [];

    // Top cap
    var capSegRadial = PI2 / capSegments;
    var topCap = [];
    var bottomCap = [];

    var r1 = topRadius;
    var r2 = bottomRadius;
    var y = height / 2;

    for (var i = 0; i < capSegments; i++) {
      var theta = i * capSegRadial;
      var x = r1 * Math.sin(theta);
      var z = r1 * Math.cos(theta);
      topCap.add(x);
      topCap.add(y);
      topCap.add(z);

      x = r2 * Math.sin(theta);
      z = r2 * Math.cos(theta);
      bottomCap.add(x);
      bottomCap.add(-y);
      bottomCap.add(z);
    }
    // Build top cap
    vertices.add(0.0);
    vertices.add(y);
    vertices.add(0.0);
    // TODO
    texCoords.add(0.0);
    texCoords.add(0.0);

    var n = capSegments;
    for (var i = 0; i < n; i++) {
      vertices.add(topCap[i * 3]);
      vertices.add(topCap[i * 3 + 1]);
      vertices.add(topCap[i * 3 + 2]);

      // TODO
      texCoords.add(i / n);
      texCoords.add(0.0);

      indices.add(0);
      indices.add(i + 1);
      indices.add((i + 1) % n + 1);
    }

    // Build bottom cap
    var offset = vertices.length ~/ 3;
    vertices.add(0.0);
    vertices.add(-y);
    vertices.add(0.0);

    texCoords.add(0.0);
    texCoords.add(1.0);

    for (var i = 0; i < n; i++) {
      vertices.add(bottomCap[i * 3]);
      vertices.add(bottomCap[i * 3 + 1]);
      vertices.add(bottomCap[i * 3 + 2]);
      // TODO
      texCoords.add(i / n);
      texCoords.add(1.0);

      indices.add(offset);
      indices.add(offset + ((i + 1) % n + 1));
      indices.add(offset + i + 1);
    }

    // Build side
    offset = vertices.length ~/ 3;
    var n2 = heightSegments;
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n2 + 1; j++) {
        var v = j / n2;
        var v3 = new Vector3.lerp(
            new Vector3(topCap[i * 3], topCap[i * 3 + 1], topCap[i * 3 + 2]),
            new Vector3(bottomCap[i * 3], bottomCap[i * 3 + 1], bottomCap[i * 3 + 2]),
            v);

        vertices.add(v3.x);
        vertices.add(v3.y);
        vertices.add(v3.z);

        texCoords.add(i / n);
        texCoords.add(v);
      }
    }
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n2; j++) {
        var i1 = i * (n2 + 1) + j;
        var i2 = ((i + 1) % n) * (n2 + 1) + j;
        var i3 = ((i + 1) % n) * (n2 + 1) + j + 1;
        var i4 = i * (n2 + 1) + j + 1;

        indices.add(offset + i2);
        indices.add(offset + i1);
        indices.add(offset + i4);

        indices.add(offset + i4);
        indices.add(offset + i3);
        indices.add(offset + i2);
      }
    }


    var mesh = new Mesh();
    mesh.vertices = vertices;
    mesh.texCoords = texCoords;
    mesh.indices = indices;
    mesh.computeNormals();
    return mesh;
  }

}
