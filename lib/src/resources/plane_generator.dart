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


class PlaneGenerator {

  static Mesh create({num width: 1.0, num height: 1.0, int subdivisions: 1, bool ground: false}) {
    var vertices = [],
        indices = [],
        texCoords = [];

    for (var row = 0; row <= subdivisions; row++) {
      for (var col = 0; col <= subdivisions; col++) {
        var px = (col * width) / subdivisions - (width / 2);
        var yorz = ((subdivisions - row) * height) / subdivisions - (height / 2.0);
        var py = ground ? 0.0 : yorz;
        var pz = ground ? yorz : 0.0;
        vertices.addAll([px.toDouble(), py, -pz.toDouble()]);
        texCoords.addAll([col / subdivisions, 1.0 - row / subdivisions]);
      }
    }

    for (var row = 0; row < subdivisions; row++) {
      for (var col = 0; col < subdivisions; col++) {
        indices.add(col + 1 + (row + 1) * (subdivisions + 1));
        indices.add(col + 1 + row * (subdivisions + 1));
        indices.add(col + row * (subdivisions + 1));

        indices.add(col + (row + 1) * (subdivisions + 1));
        indices.add(col + 1 + (row + 1) * (subdivisions + 1));
        indices.add(col + row * (subdivisions + 1));
      }
    }

    var mesh = new Mesh();
    mesh.vertices = vertices;
    mesh.texCoords = texCoords;
    mesh.indices = indices;
    mesh.computeNormals();
    return mesh;
  }

//  static Mesh fromHightMap(String url, {String name, num width: 1.0, num height: 1.0, num minHeight, num maxHeight,
//      int subdivisions: 1}) {
//    var img = new html.ImageElement(src: url);
//    img.onLoad.listen((_) {
//      var canvas = new html.CanvasElement();
//      var ctx = canvas.getContext("2d");
//      var mw = img.width;
//      var mh = img.height;
//      canvas.width = mw;
//      canvas.height = mh;
//      ctx.drawImage(img, 0, 0);
//      var buffer = ctx.getImageData(0, 0, mw, mh);
//      createFromHightMap(width, height, subdivisions, minHeight, maxHeight, buffer, mw, mh);
//    });
//  }

  /// from BabylonJS
  static Mesh createFromHightMap(num width, num height, int subdivisions, num minHeight, num maxHeight,
      html.ImageData imageData, int bufferWidth, int bufferHeight) {
    var buffer = imageData.data;
    var indices = [];
    var vertices = [];
    var texCoords = [];
    var row, col;

    // Vertices
    for (row = 0; row <= subdivisions; row++) {
      for (col = 0; col <= subdivisions; col++) {
        var position = new Vector3(
            (col * width) / subdivisions - (width / 2.0),
            0.0,
            ((subdivisions - row) * height) / subdivisions - (height / 2.0));

        // Compute height
        var heightMapX = (((position.x + width / 2) / width) * (bufferWidth - 1)).toInt() | 0;
        var heightMapY = ((1.0 - (position.z + height / 2) / height) * (bufferHeight - 1)).toInt() | 0;

        var pos = (heightMapX + heightMapY * bufferWidth) * 4;
        var r = buffer[pos] / 255.0;
        var g = buffer[pos + 1] / 255.0;
        var b = buffer[pos + 2] / 255.0;

        var gradient = r * 0.3 + g * 0.59 + b * 0.11;

        position.y = minHeight + (maxHeight - minHeight) * gradient;

        // Add  vertex
        vertices.addAll([position.x, position.y, -position.z]);
        texCoords.addAll([col / subdivisions, 1.0 - row / subdivisions]);
      }
    }

    // Indices
    for (row = 0; row < subdivisions; row++) {
      for (col = 0; col < subdivisions; col++) {
        indices.add(col + 1 + (row + 1) * (subdivisions + 1));
        indices.add(col + 1 + row * (subdivisions + 1));
        indices.add(col + row * (subdivisions + 1));

        indices.add(col + (row + 1) * (subdivisions + 1));
        indices.add(col + 1 + (row + 1) * (subdivisions + 1));
        indices.add(col + row * (subdivisions + 1));
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
