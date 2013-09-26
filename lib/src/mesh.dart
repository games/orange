part of orange;


class Mesh extends Transform {
  bool useSharedVertices;
  bool wireframe = false;
  Geometry _geometry;
  Material material;
  
  List<int> _faces;
  gl.Buffer _faceBuffer;
  
  List<Mesh> _subMeshes;
  
  render() {
    updateMatrix();
    
    Renderer renderer = _director.renderer;
    
    if(_geometry != null) {
      _geometry.prepare(renderer);
    }
    
    if(material != null) {
      if(material.shader == null)
        material.shader = Shader.simpleShader;
      material.shader.compile();
      material.shader.use();
      material.shader.setupAttributes(this);
      material.shader.setupUniforms(this);
      material.shader.setupLights(_director.scene.lights);
    }
    
    if(_faceBuffer == null && _faces != null) {
      _faceBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _faceBuffer);
      renderer.ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(_faces), gl.STATIC_DRAW);
    }
    
    if(_subMeshes != null && _subMeshes.length > 0) {
      _subMeshes.forEach((Mesh e) {
        e.position = position.clone();
        e.rotation = rotation.clone();
        e.scale = scale.clone();
        if(e.useSharedVertices)
          e._geometry = _geometry;
        e.render(); 
      });
    } else {
      if(!wireframe && _faceBuffer != null) {
        renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _faceBuffer);
        renderer.ctx.drawElements(gl.TRIANGLES, _faces.length, gl.UNSIGNED_SHORT, 0);
      } else if(wireframe) {
        renderer.ctx.drawArrays(gl.LINE_STRIP, 0, _geometry.vertices.length ~/ 3);
      }
    }
  }
  
  
  computeFaceNormals() {
    if(_faces == null)
      return;
    var faceNormals = new List.filled(_faces.length, null);
    var vertices = _geometry.vertices;
    var startVertex = 0;
    for(var i = 0; i < _faces.length; i += 3) {
      startVertex = _faces[i] * 3;
      var v0 = new Vector3(vertices[startVertex], vertices[startVertex + 1], vertices[startVertex + 2]);
      startVertex = _faces[i + 1] * 3;
      var v1 = new Vector3(vertices[startVertex], vertices[startVertex + 1], vertices[startVertex + 2]);
      startVertex = _faces[i + 2] * 3;
      var v2 = new Vector3(vertices[startVertex], vertices[startVertex + 1], vertices[startVertex + 2]);
      var edge0 = v1 - v0;
      var edge1 = v2 - v0;
      var normal = edge0.cross(edge1).normalize();
      for(var j = 0; j < 3; j++) {
        var vertex = _faces[i + j];
        if(faceNormals[vertex] == null) {
          faceNormals[vertex] = normal.clone();
        }
      }
    }
    var vertexNormal = [];
    faceNormals.forEach((fn) {
      if(fn != null) {
        vertexNormal.add(fn.x);
        vertexNormal.add(fn.y);
        vertexNormal.add(fn.z);
      }
    });
    _geometry.normals = vertexNormal;
  }
  
  
  computeVertexNormals() {
    if(_faces == null)
      return;
    var faceNormals = new List.filled(_faces.length, null);
    var vertices = _geometry.vertices;
    var startVertex = 0;
    for(var i = 0; i < _faces.length; i += 3) {
      startVertex = _faces[i] * 3;
      var v0 = new Vector3(vertices[startVertex].toDouble(), vertices[startVertex + 1].toDouble(), vertices[startVertex + 2].toDouble());
      startVertex = _faces[i + 1] * 3;
      var v1 = new Vector3(vertices[startVertex].toDouble(), vertices[startVertex + 1].toDouble(), vertices[startVertex + 2].toDouble());
      startVertex = _faces[i + 2] * 3;
      var v2 = new Vector3(vertices[startVertex].toDouble(), vertices[startVertex + 1].toDouble(), vertices[startVertex + 2].toDouble());
      var edge0 = v1 - v0;
      var edge1 = v2 - v0;
      var normal = edge0.cross(edge1).normalize();
      for(var j = 0; j < 3; j++) {
        var vertex = _faces[i + j];
        if(faceNormals[vertex] == null) {
          faceNormals[vertex] = normal.clone();
        } else {
          faceNormals[vertex] = (normal.clone() + (faceNormals[vertex])).normalize();
        }
      }
    }
    var vertexNormal = [];
    faceNormals.forEach((fn) {
      if(fn != null) {
        vertexNormal.add(fn.x);
        vertexNormal.add(fn.y);
        vertexNormal.add(fn.z);
      }
    });
    _geometry.normals = vertexNormal;
  }
}



Mesh parseMesh(String jsonStr) {
  var jsonObj = json.parse(jsonStr);
  
  var mesh = new Mesh();
  
  mesh._geometry = parseGeometry(jsonObj["sharedgeometry"]);
  mesh.material = parseMaterial(jsonObj["material"]);
  mesh._faces = parseFaces(jsonObj["faces"]);
  
  var submeshes = jsonObj["submeshes"];
  mesh._subMeshes = new List.generate(submeshes.length, (index) {
    var submesh = submeshes[index];
    var sub =  new Mesh();
    sub.useSharedVertices = submesh['usesharedvertices'];
    if(!sub.useSharedVertices) {
      sub._geometry = parseGeometry(submesh["geometry"]);
    }
    sub.material = parseMaterial(submesh["material"]);
    sub._faces = parseFaces(submesh["faces"]);
    return sub;
  });
  
  return mesh;
}

Material parseMaterial(materialJson) {
  if(materialJson == null)
    return null;
  var material = new Material();
  material.textureSource = materialJson["texture"];
  material.shader = Shader.simpleShader;
  
  var ambient = materialJson["ambient"];
  material.ambient = new List.generate(ambient.length, (i) {
    return ambient[i].toDouble();
  });

  var diffuse = materialJson["diffuse"];
  material.diffuse = new List.generate(diffuse.length, (i) {
    return diffuse[i].toDouble();
  });
  
  var specular = materialJson["specular"];
  material.specular = new List.generate(specular.length, (i) {
    return specular[i].toDouble();
  });
  
  var emissive = materialJson["emissive"];
  material.emissive = new List.generate(emissive.length, (i) {
    return emissive[i].toDouble();
  });
  
  return material;
}

List parseFaces(faceJson) {
  if(faceJson == null)
    return null;
  return new List.generate(faceJson.length, (i) {
    return faceJson[i].toInt();
  });
}

Geometry parseGeometry(geo_dict) {
  if(geo_dict == null)
    return null;
  var geometry = new Geometry();
  var vertices = geo_dict["vertices"];
  geometry.vertices = new List.generate(vertices.length, (index) {
    return vertices[index].toDouble();
  });
  var normals = geo_dict["normals"];
  geometry.normals = new List.generate(normals.length, (index) {
    return normals[index].toDouble();
  });
  var textureCoords = geo_dict["texturecoords"];
  geometry.textureCoords = new List.generate(textureCoords.length, (index) {
    return textureCoords[index].toDouble();
  });
  return geometry;
}





















