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


class SphereGenerator {

  static Mesh create({int widthSegments: 20, int heightSegments: 20, num phiStart: 0, num phiLength: PI2,
      num thetaStart: 0, thetaLength: Math.PI, radius: 1}) {

    var vertices = [];
    var texCoords = [];
    var indices = [];


    var x, y, z, u, v, i, j;

    for (j = 0; j <= heightSegments; j++) {
      for (i = 0; i <= widthSegments; i++) {
        u = i / widthSegments;
        v = j / heightSegments;

        x = -radius * Math.cos(phiStart + u * phiLength) * Math.sin(thetaStart + v * thetaLength);
        y = radius * Math.cos(thetaStart + v * thetaLength);
        z = radius * Math.sin(phiStart + u * phiLength) * Math.sin(thetaStart + v * thetaLength);

        vertices.add(x);
        vertices.add(y);
        vertices.add(z);

        texCoords.add(u);
        texCoords.add(v);
      }
    }

    var p1, p2, p3, i1, i2, i3, i4;
    var len = widthSegments + 1;
    for (j = 0; j < heightSegments; j++) {
      for (i = 0; i < widthSegments; i++) {
        i2 = j * len + i;
        i1 = (j * len + i + 1);
        i4 = (j + 1) * len + i + 1;
        i3 = (j + 1) * len + i;

        indices.add(i1);
        indices.add(i2);
        indices.add(i4);
        indices.add(i2);
        indices.add(i3);
        indices.add(i4);
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
