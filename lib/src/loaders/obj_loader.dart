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
          normals = [];
      lines.forEach((line) {
        line = line.trim();
        if (line.length == 0) return;
        if (line.startsWith("v ")) {
          vertices.addAll(line.replaceFirst("v", "").trim().split(" ").map((e) => double.parse(e)));
        } else if (line.startsWith("f ")) {
          indices.addAll(line.replaceFirst("f", "").trim().split(" ").map((e){
            var f;
            if(e.contains("/")) {
              f = e.split("/").first;
            } else {
              f = e;
            }
            return int.parse(f) - 1;
          }));
        } else if (line.startsWith("vt ")) {
          var iter = line.replaceFirst("vt", "").trim().split(" ").map((e) => double.parse(e));
          uvs.add(iter.first);
          uvs.add(iter.elementAt(1));
        } else if (line.startsWith("vn ")) {
//          normals.addAll(line.replaceFirst("vn", "").trim().split(" ").map((e) => double.parse(e)));
        }
      });
      _mesh.setPositions(vertices);
      _mesh.setIndices(indices);
      _mesh.setTexCoords(uvs);
      
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
