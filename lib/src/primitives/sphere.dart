part of orange;



class Sphere extends PolygonMesh {
  
  Sphere(int longitudeBands, int latitudeBands, double radius) {
    geometry = new Geometry();
    var vertexPositionData = [];
    var normalData = [];
    var textureCoordData = [];
    for (var latNumber = 0; latNumber <= latitudeBands; latNumber++) {
      var theta = latNumber * math.PI / latitudeBands;
      var sinTheta = math.sin(theta);
      var cosTheta = math.cos(theta);

      for (var longNumber = 0; longNumber <= longitudeBands; longNumber++) {
        var phi = longNumber * 2 * math.PI / longitudeBands;
        var sinPhi = math.sin(phi);
        var cosPhi = math.cos(phi);

        var x = cosPhi * sinTheta;
        var y = cosTheta;
        var z = sinPhi * sinTheta;
        var u = 1 - (longNumber / longitudeBands);
        var v = 1 - (latNumber / latitudeBands);

        normalData.add(x);
        normalData.add(y);
        normalData.add(-z);
        textureCoordData.add(u);
        textureCoordData.add(v);
        vertexPositionData.add(radius * x);
        vertexPositionData.add(radius * y);
        vertexPositionData.add(radius * z);
      }
    }
    setVertexes(vertexPositionData);
    setNormals(normalData);
    setTexCoords(textureCoordData);
    
    var indexData = [];
    for (var latNumber = 0; latNumber < latitudeBands; latNumber++) {
      for (var longNumber = 0; longNumber < longitudeBands; longNumber++) {
        var first = (latNumber * (longitudeBands + 1)) + longNumber;
        var second = first + longitudeBands + 1;
        indexData.add(first);
        indexData.add(second);
        indexData.add(first + 1);

        indexData.add(second);
        indexData.add(second + 1);
        indexData.add(first + 1);
      }
    }
    setFaces(indexData);
  }
}













