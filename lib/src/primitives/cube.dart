part of orange;





class Cube extends PolygonMesh {
  Cube({num width: 1.0, num height: 1.0, num depth: 1.0}) {

    var w = width * 0.5;
    var h = height * 0.5;
    var d = depth * 0.5;

    var vertices = [],
        faces = [],
        texcoords = [];
    // Front
    vertices.addAll([w, h, d]);
    vertices.addAll([-w, h, d]);
    vertices.addAll([-w, -h, d]);
    vertices.addAll([w, -h, d]);
    // Back
    vertices.addAll([w, -h, -d]);
    vertices.addAll([-w, -h, -d]);
    vertices.addAll([-w, h, -d]);
    vertices.addAll([w, h, -d]);
    // Right
    vertices.addAll([w, -h, d]);
    vertices.addAll([w, -h, -d]);
    vertices.addAll([w, h, -d]);
    vertices.addAll([w, h, d]);
    // Left
    vertices.addAll([-w, h, d]);
    vertices.addAll([-w, h, -d]);
    vertices.addAll([-w, -h, -d]);
    vertices.addAll([-w, -h, d]);
    // Top
    vertices.addAll([w, h, d]);
    vertices.addAll([w, h, -d]);
    vertices.addAll([-w, h, -d]);
    vertices.addAll([-w, h, d]);
    // Bottom
    vertices.addAll([-w, -h, d]);
    vertices.addAll([-w, -h, -d]);
    vertices.addAll([w, -h, -d]);
    vertices.addAll([w, -h, d]);

    // Front
    texcoords.addAll([1.0, 0.0]);
    texcoords.addAll([0.0, 0.0]);
    texcoords.addAll([0.0, 1.0]);
    texcoords.addAll([1.0, 1.0]);

    // Back
    texcoords.addAll([0.0, 1.0]);
    texcoords.addAll([1.0, 1.0]);
    texcoords.addAll([1.0, 0.0]);
    texcoords.addAll([0.0, 0.0]);

    // Right
    texcoords.addAll([0.0, 1.0]);
    texcoords.addAll([1.0, 1.0]);
    texcoords.addAll([1.0, 0.0]);
    texcoords.addAll([0.0, 0.0]);

    // Left
    texcoords.addAll([1.0, 0.0]);
    texcoords.addAll([0.0, 0.0]);
    texcoords.addAll([0.0, 1.0]);
    texcoords.addAll([1.0, 1.0]);

    // Top
    texcoords.addAll([1.0, 1.0]);
    texcoords.addAll([1.0, 0.0]);
    texcoords.addAll([0.0, 0.0]);
    texcoords.addAll([0.0, 1.0]);

    // Bottom
    texcoords.addAll([0.0, 0.0]);
    texcoords.addAll([0.0, 1.0]);
    texcoords.addAll([1.0, 1.0]);
    texcoords.addAll([1.0, 0.0]);

    faces.addAll([0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7, 8, 9, 10, 8, 10, 11, 12, 13, 14, 12, 14, 15, 16, 17, 18, 16, 18, 19, 20, 21, 22, 20, 22, 23]);

    setPositions(vertices);
    setTexCoords(texcoords);
    setIndices(faces);
    calculateSurfaceNormals();

  }
}












