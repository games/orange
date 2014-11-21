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

class OBJLoader {
  Mesh _mesh;
  Uri _uri;

  Future<Mesh> load(String url) {
    _uri = Uri.parse(url);
    _mesh = new Mesh();
    var completer = new Completer<Mesh>();
    html.HttpRequest.getString(url).then((String rsp) {
      var lines = rsp.split("\n");
      var vertices = [],
          indices = [],
          uvs = [],
          finalUvs = [],
          normals = [],
          finalNormals = [];
      lines.forEach((line) {
        line = line.trim();
        if (line.length == 0) return;
        if (line.startsWith("v ")) {
          vertices.addAll(line.replaceFirst("v", "").trim().split(" ").map((e) => double.parse(e)));
        } else if (line.startsWith("f ")) {
          indices.addAll(line.replaceFirst("f", "").trim().split(" ").map((e) {
            int f;
            if (e.contains("/")) {
              var fs = e.split("/");
              f = int.parse(fs.first) - 1;

              var vt = (int.parse(fs[1]) - 1) * 2;
              var vi = f * 2;
              finalUvs[vi] = uvs[vt];
              finalUvs[vi + 1] = uvs[vt + 1];

              var vn = fs.length == 3 ? int.parse(fs[2]) : null;
              if (vn != null) {
                var nv = (vn - 1) * 3;
                var ni = f * 3;
                finalNormals[ni] = normals[nv];
                finalNormals[ni + 1] = normals[nv + 1];
                finalNormals[ni + 2] = normals[nv + 2];
              }
            } else {
              f = int.parse(e) - 1;
            }
            return f;
          }));
        } else if (line.startsWith("vt ")) {
          var iter = line.replaceFirst("vt", "").trim().split(" ").map((e) => double.parse(e));
          var u = iter.first;
          var v = iter.elementAt(1);
          uvs.add(u);
          uvs.add(v);
          finalUvs.add(u);
          finalUvs.add(v);
        } else if (line.startsWith("vn ")) {
          var vn = line.replaceFirst("vn ", "").trim().split(" ").map((e) => double.parse(e));
          normals.addAll(vn);
          finalNormals.addAll(vn);
        }
      });
      
      _mesh.vertices = vertices;
      _mesh.indices = indices;
      _mesh.texCoords = finalUvs;

      if (finalNormals.length > 0) {
        _mesh.normals = finalNormals;
      } else {
        _mesh.computeNormals();
      }
      
      completer.complete(_mesh);
    });
    return completer.future;
  }
}
