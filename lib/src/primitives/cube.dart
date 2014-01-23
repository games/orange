part of orange;



class Cube extends PolygonMesh {

  Cube({num width: 1.0, num height: 1.0, num depth: 1.0, int widthSegments: 1, int heightSegments: 1, int depthSegments: 1}) {
    var width_half = width / 2;
    var height_half = height / 2;
    var depth_half = depth / 2;
    var vertices = [], faces = [], texcoords = [], normals = [];
    var buildPlane = (u, v, udir, vdir, width, height, depth, materialIndex) {
      var w, ix, iy,
      gridX = widthSegments,
      gridY = heightSegments,
      width_half = width / 2,
      height_half = height / 2,
      offset = vertices.length ~/ 3;

      if(( u == 0 && v == 1) || (u == 1 && v == 0)) {
        w = 2;
      } else if((u == 0 && v == 2) || (u == 2 && v == 0)) {
        w = 1;
        gridY = depthSegments;
      } else if ((u == 2 && v == 1) || (u == 1 && v == 2)) {
        w = 0;
        gridX = depthSegments;
      }

      var gridX1 = gridX + 1,
          gridY1 = gridY + 1,
          segment_width = width / gridX,
          segment_height = height / gridY,
          normal = new Vector3.zero();

      normal[w] = depth > 0.0 ? 1.0 : - 1.0;

      for (iy = 0; iy < gridY1; iy ++) {
        for (ix = 0; ix < gridX1; ix++) {
          var vector = new Vector3.zero();
          vector[u] = ( ix * segment_width - width_half ) * udir;
          vector[v] = ( iy * segment_height - height_half ) * vdir;
          vector[w] = depth;
          vertices.add(vector.x);
          vertices.add(vector.y);
          vertices.add(vector.z);
        }
      }

      for (iy = 0; iy < gridY; iy++) {
        for (ix = 0; ix < gridX; ix++) {
          var a = ix + gridX1 * iy;
          var b = ix + gridX1 * (iy + 1);
          var c = (ix + 1) + gridX1 * (iy + 1);
          var d = (ix + 1) + gridX1 * iy;

          var uva = new Vector2(ix / gridX, 1 - iy / gridY);
          var uvb = new Vector2(ix / gridX, 1 - (iy + 1) / gridY);
          var uvc = new Vector2((ix + 1) / gridX, 1 - (iy + 1) / gridY);
          var uvd = new Vector2((ix + 1) / gridX, 1 - iy / gridY);
          
          faces.add((a + offset).toInt());
          faces.add((b + offset).toInt());
          faces.add((d + offset).toInt());
          
          texcoords.add(uva.x);
          texcoords.add(uva.y);
          
          texcoords.add(uvb.x);
          texcoords.add(uvb.y);
          
          texcoords.add(uvd.x);
          texcoords.add(uvd.y);
          
          faces.add((b + offset).toInt());
          faces.add((c + offset).toInt());
          faces.add((d + offset).toInt());
          
          texcoords.add(uvb.x);
          texcoords.add(uvb.y);
          texcoords.add(uvc.x);
          texcoords.add(uvc.y);
          texcoords.add(uvd.x);
          texcoords.add(uvd.y);
          
          for(var i = 0; i < 6; i++) {
            normals.add(normal.x);
            normals.add(normal.y);
            normals.add(normal.z);
          }
        }
      }
    };
    
    buildPlane(2, 1, -1, -1, depth, height, width_half, 0); // px
    buildPlane(2, 1, 1, -1, depth, height, -width_half, 1); // nx
    buildPlane(0, 2, 1, 1, width, depth, height_half, 2); // py
    buildPlane(0, 2, 1, -1, width, depth, -height_half, 3); // ny
    buildPlane(0, 1, 1, -1, width, height, depth_half, 4); // pz
    buildPlane(0, 1, -1, -1, width, height, -depth_half, 5); // nz
    
    setVertices(vertices);
    setTexCoords(texcoords);
    setFaces(faces);
    setNormals(normals);
//    generateFacesNormals();
  }
    
}


























