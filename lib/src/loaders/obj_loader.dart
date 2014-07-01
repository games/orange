part of orange;




class ObjLoader {
  PolygonMesh _mesh;
  Uri _uri;

  Future<Mesh> load(String url) {
    _uri = Uri.parse(url);
    _mesh = new PolygonMesh();
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
          indices.addAll(line.replaceFirst("f", "").trim().split(" ").map((e){
            int f;
            if(e.contains("/")) {
              var fs = e.split("/");
              f = int.parse(fs.first) - 1;
              
              var vt = (int.parse(fs[1]) - 1) * 2;
              var vi = f * 2;
              finalUvs[vi] = uvs[vt];
              finalUvs[vi + 1] = uvs[vt + 1];
              
              var vn = fs.length == 3 ? int.parse(fs[2]) : null;
              if(vn != null) {
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
      _mesh.setPositions(vertices);
      _mesh.setIndices(indices);
      _mesh.setTexCoords(finalUvs);
      
      if(finalNormals.length > 0) {
        _mesh.setNormals(finalNormals);
      } else {
        _mesh.calculateSurfaceNormals();
      }
      completer.complete(_mesh);
    });
    return completer.future;
  }
}
