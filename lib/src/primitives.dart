part of orange;


class Cube extends Mesh {
  Cube(num width, num height, num depth) {
    
    num hw = width / 2;
    num hh = height / 2;
    num hd = depth / 2;
    
    _geometry = new Geometry();
    _geometry.vertices = [
                          // Front face
                          -hw, -hh,  hd,
                          hw, -hh,  hd,
                          hw,  hh,  hd,
                          -hw,  hh,  hd,
                          
                          // Back face
                          -hw, -hh, -hd,
                          -hw,  hh, -hd,
                          hw,  hh, -hd,
                          hw, -hh, -hd,
                          
                          // Top face
                          -hw,  hh, -hd,
                          -hw,  hh,  hd,
                          hw,  hh,  hd,
                          hw,  hh, -hd,
                          
                          // Bottom face
                          -hw, -hh, -hd,
                          hw, -hh, -hd,
                          hw, -hh,  hd,
                          -hw, -hh,  hd,
                          
                          // Right face
                          hw, -hh, -hd,
                          hw,  hh, -hd,
                          hw,  hh,  hd,
                          hw, -hh,  hd,
                          
                          // Left face
                          -hw, -hh, -hd,
                          -hw, -hh,  hd,
                          -hw,  hh,  hd,
                          -hw,  hh, -hd
                          ];
    
    _geometry.normals = [
                         // Front face
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         
                         // Back face
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         
                         // Top face
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         
                         // Bottom face
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         
                         // Right face
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         
                         // Left face
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0
                         ];
    
    _faces = [
               0, 1, 2,      0, 2, 3,    // Front face
               4, 5, 6,      4, 6, 7,    // Back face
               8, 9, 10,     8, 10, 11,  // Top face
               12, 13, 14,   12, 14, 15, // Bottom face
               16, 17, 18,   16, 18, 19, // Right face
               20, 21, 22,   20, 22, 23  // Left face
             ];
    
    _material = new Material();
    _material.shader = Shader.simpleColorShader;
  }
}





