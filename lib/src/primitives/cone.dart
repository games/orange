part of orange;



class Cone extends PolygonMesh {
  
  Cone({num topRadius: 0, num bottomRadius: 1, num height: 2, num capSegments: 50, num heightSegments: 1}) {
    
    geometry = new Geometry();
    
    var positions = [];
    var texcoords = [];
    var faces = [];
    positions.length = 0;
    texcoords.length = 0;
    
    // Top cap
    var capSegRadial = math.PI * 2 / capSegments;
    var topCap = [];
    var bottomCap = [];

    var r1 = topRadius;
    var r2 = bottomRadius;
    var y = height / 2;

    for (var i = 0; i < capSegments; i++) {
      var theta = i * capSegRadial;
      var x = r1 * math.sin(theta);
      var z = r1 * math.cos(theta);
      topCap.add(x);
      topCap.add(y);
      topCap.add(z);
      x = r2 * math.sin(theta);
      z = r2 * math.cos(theta);
      bottomCap.add(x);
      bottomCap.add(-y);
      bottomCap.add(z);
    }

    // Build top cap
    positions.add(0.0);
    positions.add(y);
    positions.add(0.0);
    // TODO
    texcoords.add(0.0);
    texcoords.add(0.0);
    
    var n = capSegments;
    for (var i = 0; i < n; i++) {
      positions.add(topCap[i]);
      positions.add(topCap[i + 1]);
      positions.add(topCap[i + 2]);
      
      // TODO
      texcoords.add(i / n);
      texcoords.add(0.0);

      faces.add(0);
      faces.add(i + 1);
      faces.add((i+1) % n + 1);
    }

    // Build bottom cap
    var offset = positions.length;
    positions.add(0.0);
    positions.add(-y);
    positions.add(0.0);

    texcoords.add(0.0);
    texcoords.add(1.0);
    
    for (var i = 0; i < n; i++) {
      positions.add(bottomCap[i]);
      positions.add(bottomCap[i + 1]);
      positions.add(bottomCap[i + 2]);
      // TODO
      texcoords.add(i / n);
      texcoords.add(1.0);

      faces.add(offset);
      faces.add(offset + ((i + 1) % n + 1));
      faces.add(offset + i + 1);
    }

    // // Build side
    offset = positions.length;
    var n2 = heightSegments;
    for (var i =0; i < n; i++) {
      for (var j = 0; j < n2+1; j++) {
        var v = j / n2;
        var v3 = lerp(new Vector3(topCap[i], topCap[i + 1], topCap[i + 2]), 
            new Vector3(bottomCap[i], bottomCap[i + 1], bottomCap[i + 2]), v);

        positions.add(v3.x);
        positions.add(v3.y);
        positions.add(v3.z);
        
        texcoords.add(i / n);
        texcoords.add(v);
      }
    }
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n2; j++) {
        var i1 = i * (n2 + 1) + j;
        var i2 = ((i + 1) % n) * (n2 + 1) + j;
        var i3 = ((i + 1) % n) * (n2 + 1) + j + 1;
        var i4 = i * (n2 + 1) + j + 1;
        
        faces.add(offset + i2);
        faces.add(offset + i1);
        faces.add(offset + i4);
        
        faces.add(offset + i4);
        faces.add(offset + i3);
        faces.add(offset + i2);
      }
    }
    
    setVertexes(positions);
    setTexCoords(texcoords);
    setFaces(faces);
    
    generateVertexNormals();
  }
  
}