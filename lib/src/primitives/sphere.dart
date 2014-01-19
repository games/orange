part of orange;



/// from nutty engine
class Sphere extends PolygonMesh {
  
  /// <param name="numSegments">Number of horizontal segments to create.</param>
  /// <param name="numRings">Number of vertical rings to create.</param>
  /// <param name="radius">Radius of the sphere.</param>
  /// <param name="cutoff">Amount of sphere to cutoff. 0.5 generates a hemisphere.</param>
  Sphere(int numSegments, int numRings, double radius, {double cutoff: 0.0}) {
    cutoff = math.max(0.0, math.min(1.0, 1.0 - cutoff));
    var actualRings = (numRings * cutoff);
    initialzie((numSegments * actualRings).toInt(), (((numSegments - 1) * 6) * (actualRings - 1)).toInt());
    
    var index = 0, point = 0;
    for(var y = 0; y < actualRings; y++) {
      var v = y / (numRings - 1.0);
      var yangle = v * math.PI;
      var ypos = math.cos(yangle) * radius;
      var r = math.sin(yangle) * radius;
      for(var x = 0; x < numSegments; x++) {
        var u = x / (numSegments - 1.0);
        var xangle = u * (2.0 * math.PI);
        setVertex(point, new Vector3(math.cos(xangle) * r, math.sin(xangle) * r, ypos));
        setTexCoord(point, new Vector2(u, v));
        
        if((y > 0) && (x < (numSegments - 1))) {
          var p = point - numSegments;
          _indices[index * 3] = p;
          _indices[index * 3 + 1] = point;
          _indices[index * 3 + 2] = point + 1;
          index++;
          
          _indices[index * 3] = point + 1;
          _indices[index * 3 + 1] = p + 1;
          _indices[index * 3 + 2] = p;
          index++;
        }
        
        point++;
      }
    }
    
    calculateNormals();
    
    for(var x = 0; x < numSegments; x++) {
      var index1 = x * 3;
      _normals[index1] = 0.0;
      _normals[index1 + 1] = 0.0;
      _normals[index1 + 2] = 1.0;
      
      if(actualRings == numRings) {
        index1 = (_vertexes.length - 3) - index1;
        _normals[index1] = 0.0;
        _normals[index1 + 1] = 0.0;
        _normals[index1 + 2] = -1.0;
      }
    }
    
    for(var y = 1; y < (actualRings - 1); y++) {
      var index1 = (y * numSegments) * 3;
      var index2 = index1 + ((numSegments - 1) * 3);
      _normals[index1] = (_normals[index1] + _normals[index2]) * 0.5;
      _normals[index1 + 1] = (_normals[index1 + 1] + _normals[index2 + 1]) * 0.5;
      _normals[index1 + 2] = (_normals[index1 + 2] + _normals[index2 + 2]) * 0.5;
      
      _normals[index2] = _normals[index1];
      _normals[index2 + 1] = _normals[index1 + 1];
      _normals[index2 + 2] = _normals[index1 + 2];
    }
    
  }
}













