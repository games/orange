part of orange;



class Plane extends PolygonMesh {
  
  Plane({int widthSegments: 1, int heightSegments: 1}) {
    
    var vertexes = [];
    var texcoords = [];
    var normals = [];
    var faces = [];
    
    for (var y = 0; y <= heightSegments; y++) {
      var t = y / heightSegments;
      for (var x = 0; x <= widthSegments; x++) {
        var s = x / widthSegments;
        vertexes.add(2.0 * s - 1);
        vertexes.add(2.0 * t - 1);
        vertexes.add(0.0);
        texcoords.add(s);
        texcoords.add(t);
        normals.add(0.0);
        normals.add(0.0);
        normals.add(1.0);
        if (x < widthSegments && y < heightSegments) {
          var i = x + y * (widthSegments + 1);
          faces.add(i);
          faces.add(i + 1);
          faces.add(i + widthSegments + 1);
          faces.add(i + widthSegments + 1);
          faces.add(i + 1);
          faces.add(i + widthSegments + 2);
        }
      }
    }
    
    setVertexes(vertexes);
    setTexCoords(texcoords);
    setNormals(normals);
    setFaces(faces);
  }
}