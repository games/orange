part of orange;



class Cube extends PolygonMesh {

  var _planeMatrix = new Matrix4.identity();
  
  Cube([int widthSegments = 1, int heightSegments = 1, int depthSegments = 1, bool inside = false]) {
    var planes = [
        _createPlane("px", depthSegments, heightSegments),
        _createPlane("nx", depthSegments, heightSegments),
        _createPlane("py", widthSegments, depthSegments),
        _createPlane("ny", widthSegments, depthSegments),
        _createPlane("pz", widthSegments, heightSegments),
        _createPlane("nz", widthSegments, heightSegments)
    ];
    var attributes = {};
    attributes[Semantics.position] = [];
    attributes[Semantics.texture] = [];
    attributes[Semantics.normal] = [];
    var faces = [];
    
    var cursor = 0;
    planes.forEach((Plane plane) {
      [Semantics.position, Semantics.texture, Semantics.normal].forEach((semantic) {
        var list = plane.geometry.buffers[semantic].data as List;
        var inverse = inside && semantic == Semantics.normal ? -1 : 1;
        for (var i = 0; i < list.length; i++) {
          attributes[semantic].add(list[i] * inverse);
        }
        list = plane._indices;
        for (var i = 0; i < list.length; i++) {
          faces.add(list[i] + cursor);
        }
      });
      cursor += plane.vertexesCount;
    });
    
    setVertexes(attributes[Semantics.position]);
    setTexCoords(attributes[Semantics.texture]);
    setNormals(attributes[Semantics.normal]);
    setFaces(faces);
  }
  
  _createPlane(pos, widthSegments, heightSegments) {
    _planeMatrix.setIdentity();
    var plane = new Plane(widthSegments: widthSegments, heightSegments: heightSegments);
    switch(pos) {
      case "px":
        _planeMatrix.translate(new Vector3(1.0, 0.0, 0.0));
        _planeMatrix.rotateY(math.PI / 2);
        break;
      case "nx":
        _planeMatrix.translate(new Vector3(-1.0, 0.0, 0.0));
        _planeMatrix.rotateY(-math.PI / 2);
        break;
      case "py":
        _planeMatrix.translate(new Vector3(0.0, 1.0, 0.0));
        _planeMatrix.rotateX(-math.PI / 2);
        break;
      case "ny":
        _planeMatrix.translate(new Vector3(0.0, -1.0, 0.0));
        _planeMatrix.rotateX(math.PI / 2);
        break;
      case "pz":
        _planeMatrix.translate(new Vector3(0.0, 0.0, 1.0));
        break;
      case "nz":
        _planeMatrix.translate(new Vector3(0.0, 0.0, -1.0));
        _planeMatrix.rotateY(math.PI);
        break;
    }
    plane.applyTransform(_planeMatrix);
    return plane;
  }
  
}


























