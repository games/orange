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

// from J3D
class Sphere extends Mesh {
  Sphere(num radius, num segmentsWidth, num segmentsHeight) {
    
    var segmentsX = math.max(3, segmentsWidth.floor());
    var segmentsY = math.max(3, segmentsHeight.floor());
    
    var phiStart = 0;
    var phiLength = math.PI * 2;
    
    var thetaStart = 0;
    var thetaLength = math.PI;
    
    var x, y;
    
    var vertices = [];
    var uvs = [];
    for(y = 0; y <= segmentsY; y++) {
      for(x = 0; x <= segmentsX; x++) {
        var u = x / segmentsX;
        var v = y / segmentsY;
        var xp = -radius * math.cos(phiStart + u * phiLength) * math.sin(thetaStart + v * thetaLength);
        var yp = radius * math.cos(thetaStart + v * thetaLength);
        var zp = radius * math.sin(phiStart + u * phiLength) * math.sin(thetaStart + v * thetaLength);
        
        vertices.add(new Vector3(xp, yp, zp));
        uvs.add(new Vector2(u, 1 - v));
      }
    }

    _geometry = new Geometry();
    _geometry.vertices = [];
    _geometry.textureCoords = [];
    _geometry.normals = [];
    _faces = [];
    for(y = 0; y < segmentsY; y++) {
      for(x = 0; x < segmentsX; x++) {
        var o = segmentsX + 1;
        var vt1 = vertices[y * o + x + 0];
        var vt2 = vertices[y * o + x + 1];
        var vt3 = vertices[(y + 1) * o + x + 1];
        var vt4 = vertices[(y + 1) * o + x + 0];

        Vector2 uv1 = uvs[ y * o + x + 0 ];
        var uv2 = uvs[ y * o + x + 1 ];
        var uv3 = uvs[ (y + 1) * o + x + 1 ];
        var uv4 = uvs[ (y + 1) * o + x + 0 ];
        
        var n1 = vt1.clone().normalize();
        var n2 = vt2.clone().normalize();
        var n3 = vt3.clone().normalize();
        var n4 = vt4.clone().normalize();

        var p = (_geometry.vertices.length / 3).floor();

        _geometry.vertices.addAll([vt1.x, vt1.y, vt1.z, vt2.x, vt2.y, vt2.z, vt3.x, vt3.y, vt3.z, vt4.x, vt4.y, vt4.z]);
        _geometry.textureCoords.addAll([uv1[0], uv1[1], uv2[0], uv2[1], uv3[0], uv3[1], uv4[0], uv4[1]]);
        _geometry.normals.addAll([n1.x, n1.y, n1.z, n2.x, n2.y, n2.z, n3.x, n3.y, n3.z, n4.x, n4.y, n4.z]);
        _faces.addAll([p + 0, p + 1, p + 2, p + 0, p + 2, p + 3]);
      }
    }
    
    _material = new Material();
    _material.shader = Shader.simpleColorShader;
    
  }
}





















