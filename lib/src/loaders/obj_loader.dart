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
          normals = [];
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
              var vn = fs.length == 3 ? int.parse(fs[2]) : null;
              var vi = f * 2;
              finalUvs[vi] = uvs[vt];
              finalUvs[vi + 1] = uvs[vt + 1];
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
          normals.addAll(line.replaceFirst("vn", "").trim().split(" ").map((e) => double.parse(e)));
        }
      });
      _mesh.setPositions(vertices);
      _mesh.setIndices(indices);
      _mesh.setTexCoords(finalUvs);
      
      if(normals.length > 0) {
        _mesh.setNormals(normals);
      } else {
        _mesh.calculateSurfaceNormals();
      }
      completer.complete(_mesh);
    });
    return completer.future;
  }
}
