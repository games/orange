part of orange;



class SphereMesh extends PolygonMesh {

  SphereMesh({String name, int widthSegments: 20, int heightSegments: 20, num phiStart: 0, num phiLength: math.PI * 2, num thetaStart: 0, thetaLength: math.PI, radius: 1}) : super(name: name) {

    var vertices = [];
    var texcoords = [];

    var x, y, z, u, v, i, j;

    for (j = 0; j <= heightSegments; j++) {
      for (i = 0; i <= widthSegments; i++) {
        u = i / widthSegments;
        v = j / heightSegments;

        x = -radius * math.cos(phiStart + u * phiLength) * math.sin(thetaStart + v * thetaLength);
        y = radius * math.cos(thetaStart + v * thetaLength);
        z = radius * math.sin(phiStart + u * phiLength) * math.sin(thetaStart + v * thetaLength);

        vertices.add(x);
        vertices.add(y);
        vertices.add(z);

        texcoords.add(u);
        texcoords.add(v);
      }
    }

    var p1, p2, p3, i1, i2, i3, i4;
    var faces = [];
    var len = widthSegments + 1;
    for (j = 0; j < heightSegments; j++) {
      for (i = 0; i < widthSegments; i++) {
        i2 = j * len + i;
        i1 = (j * len + i + 1);
        i4 = (j + 1) * len + i + 1;
        i3 = (j + 1) * len + i;

        faces.add(i1);
        faces.add(i2);
        faces.add(i4);
        faces.add(i2);
        faces.add(i3);
        faces.add(i4);
      }
    }

    setPositions(vertices);
    setTexCoords(texcoords);
    setIndices(faces);
    calculateSurfaceNormals();
  }
}











