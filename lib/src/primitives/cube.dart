part of orange;


/// from nutty engine
class Cube extends PolygonMesh {
  Cube(double x, double y, double z) {
    
    initialzie(12, 12 * 3);
    
    setVertex(0, new Vector3(-x, -y, -z));
    setVertex(1, new Vector3(x, -y, -z));
    setVertex(2, new Vector3(x, y, -z));
    setVertex(3, new Vector3(-x, y, -z));
    
    setVertex(4, new Vector3(-x, -y, z));
    setVertex(5, new Vector3(x, -y, z));
    setVertex(6, new Vector3(x, y, z));
    setVertex(7, new Vector3(-x, y, z));
    
    setVertex(8, new Vector3(-x, y, z));
    setVertex(9, new Vector3(x, y, z));
    setVertex(10, new Vector3(-x, -y, z));
    setVertex(11, new Vector3(x, -y, z));
    
    setTexCoord(0, new Vector2(0.0, 0.0));
    setTexCoord(1, new Vector2(1.0, 0.0));
    setTexCoord(2, new Vector2(1.0, 1.0));
    setTexCoord(3, new Vector2(0.0, 1.0));
    
    setTexCoord(4, new Vector2(1.0, 0.0));
    setTexCoord(5, new Vector2(0.0, 0.0));
    setTexCoord(6, new Vector2(0.0, 1.0));
    setTexCoord(7, new Vector2(1.0, 1.0));
    
    setTexCoord(8, new Vector2(0.0, 0.0));
    setTexCoord(9, new Vector2(1.0, 0.0));
    setTexCoord(10, new Vector2(0.0, 1.0));
    setTexCoord(11, new Vector2(1.0, 1.0));
    
    // back
    _indices[0] = 0; 
    _indices[1] = 3;
    _indices[2] = 2; 
    _indices[3] = 2;
    _indices[4] = 1; 
    _indices[5] = 0;
    
    // left
    _indices[6] = 0; 
    _indices[7] = 4;
    _indices[8] = 7; 
    _indices[9] = 7;
    _indices[10] = 3; 
    _indices[11] = 0;
    
    // bottom
    _indices[12] = 0; 
    _indices[13] = 1;
    _indices[14] = 11; 
    _indices[15] = 11;
    _indices[16] = 10; 
    _indices[17] = 0;
    
    // front
    _indices[18] = 5; 
    _indices[19] = 6;
    _indices[20] = 7; 
    _indices[21] = 7;
    _indices[22] = 4; 
    _indices[23] = 5;
    
    // right
    _indices[24] = 5; 
    _indices[25] = 1;
    _indices[26] = 2; 
    _indices[27] = 2;
    _indices[28] = 6; 
    _indices[29] = 5;

    // top
    _indices[30] = 9; 
    _indices[31] = 2;
    _indices[32] = 3; 
    _indices[33] = 3;
    _indices[34] = 8; 
    _indices[35] = 9;
    
    calculateNormals();
  }
}













