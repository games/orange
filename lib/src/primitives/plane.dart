part of orange;



class Plane extends PolygonMesh {
  
  Plane({num width: 1.0, num height: 1.0, int widthSegments: 1, int heightSegments: 1}) {
    var vertices = [];
    var texcoords = [];
    var faces = [];
    
    var ix, iz;
    var width_half = width / 2;
    var height_half = height / 2;

    var gridX = widthSegments;
    var gridZ = heightSegments;

    var gridX1 = gridX + 1;
    var gridZ1 = gridZ + 1;

    var segment_width = width / gridX;
    var segment_height = height / gridZ;

    for (iz = 0; iz < gridZ1; iz++) {
      for (ix = 0; ix < gridX1; ix++) {
        var x = ix * segment_width - width_half;
        var y = iz * segment_height - height_half;
        vertices.add(x);
        vertices.add(-y);
        vertices.add(0.0);
      }
    }

    for (iz = 0; iz < gridZ; iz++) {
      for ( ix = 0; ix < gridX; ix ++ ) {
        var a = ix + gridX1 * iz;
        var b = ix + gridX1 * (iz + 1);
        var c = (ix + 1) + gridX1 * (iz + 1);
        var d = (ix + 1) + gridX1 * iz;
        
        faces.add(a);
        faces.add(b);
        faces.add(d);
        
        texcoords.add(ix / gridX);
        texcoords.add(1 - iz / gridZ);
        
        texcoords.add(ix / gridX);
        texcoords.add(1 - ( iz + 1 ) / gridZ);
        
        texcoords.add(( ix + 1 ) / gridX);
        texcoords.add(1 - iz / gridZ);
        
        faces.add(b);
        faces.add(c);
        faces.add(d);
        
        texcoords.add(ix / gridX);
        texcoords.add(1 - ( iz + 1 ) / gridZ);
        
        texcoords.add(( ix + 1 ) / gridX);
        texcoords.add(1 - ( iz + 1 ) / gridZ);
        
        texcoords.add(( ix + 1 ) / gridX);
        texcoords.add(1 - iz / gridZ);
      }
    }
    
    setVertexes(vertices);
    setTexCoords(texcoords);
    setFaces(faces);
    generateFacesNormals();
  }
}