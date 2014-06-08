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
          indices = [];
      lines.forEach((line) {
        line = line.trim();
        if (line.length == 0) return;
        if (line.startsWith("v ")) {
          vertices.addAll(line.replaceFirst("v", "").trim().split(" ").map((e) => double.parse(e)));
        }
        if (line.startsWith("f ")) {
          indices.addAll(line.replaceFirst("f", "").trim().split(" ").map((e) => int.parse(e) - 1));
        }
      });
      _mesh.setVertices(vertices);
      _mesh.setFaces(indices);
      _mesh.calculateSurfaceNormals();
      completer.complete(_mesh);
    });
    return completer.future;
  }
}
