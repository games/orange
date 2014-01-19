part of orange;



/// from nutty engine
class Plane extends PolygonMesh {
  
  Plane(double x, double y) {
    initialzie(4, 6);
    
    setVertex(0, new Vector3(-x, -y, 0.0));
    setVertex(1, new Vector3(x, -y, 0.0));
    setVertex(2, new Vector3(x, y, 0.0));
    setVertex(3, new Vector3(-x, y, 0.0));

    setTexCoord(0, new Vector2(0.0, 0.0));
    setTexCoord(1, new Vector2(1.0, 0.0));
    setTexCoord(2, new Vector2(1.0, 1.0));
    setTexCoord(3, new Vector2(0.0, 1.0));

    _indices[0] = 0;
    _indices[1] = 1;
    _indices[2] = 2;

    _indices[3] = 2;
    _indices[4] = 3;
    _indices[5] = 0;

    calculateNormals();
  }
  
}