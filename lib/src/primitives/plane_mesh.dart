part of orange;



class PlaneMesh extends PolygonMesh {

  PlaneMesh({String name, num width: 1.0, num height: 1.0, int subdivisions: 1, bool ground: false})
      : super(name: name) {
    
    var vertices = [];
    var texcoords = [];
    var faces = [];

    for (var row = 0; row <= subdivisions; row++) {
      for (var col = 0; col <= subdivisions; col++) {
        var px = (col * width) / subdivisions - (width / 2);
        var yorz = ((subdivisions - row) * height) / subdivisions - (height / 2.0);
        var py = ground ? 0.0 : yorz;
        var pz = ground ? yorz : 0.0;
        vertices.addAll([px.toDouble(), py, -pz.toDouble()]);
        texcoords.addAll([col / subdivisions, 1.0 - row / subdivisions]);
      }
    }
    for (var row = 0; row < subdivisions; row++) {
      for (var col = 0; col < subdivisions; col++) {
        faces.add(col + 1 + (row + 1) * (subdivisions + 1));
        faces.add(col + 1 + row * (subdivisions + 1));
        faces.add(col + row * (subdivisions + 1));

        faces.add(col + (row + 1) * (subdivisions + 1));
        faces.add(col + 1 + (row + 1) * (subdivisions + 1));
        faces.add(col + row * (subdivisions + 1));
      }
    }

    setVertices(vertices);
    setTexCoords(texcoords);
    setFaces(faces);
    calculateSurfaceNormals();
  }
}







