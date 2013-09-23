part of orange;


class Mesh extends Transform {
  bool useSharedVertices;
  bool wireframe = false;
  Geometry _geometry;
  Material _material;
  
  List<int> _faces;
  gl.Buffer _faceBuffer;
  
  List<Mesh> _subMeshes;
  
  render() {
    updateMatrix();
    
    Renderer renderer = _director.renderer;
    
    if(_geometry != null) {
      _geometry.prepare(renderer);
    }
    
    if(_material != null) {
      if(_material.shader == null)
        _material.shader = Shader.simpleShader;
      _material.shader.compile();
      _material.shader.use();
      _material.shader.setupAttributes(this);
      _material.shader.setupUniforms(this);
      _material.shader.setupLights(_director.scene.lights);
    }
    
    if(_faceBuffer == null && _faces != null) {
      _faceBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _faceBuffer);
      renderer.ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(_faces), gl.STATIC_DRAW);
    }
    
    if(_subMeshes != null) {
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
        renderer.ctx.drawArrays(gl.LINE_STRIP, 0, (_geometry.vertices.length / 3).toInt());
      }
    }
  }
}



Mesh parseMesh(String jsonStr) {
  var jsonObj = json.parse(jsonStr);
  
  var mesh = new Mesh();
  
  mesh._geometry = parseGeometry(jsonObj["sharedgeometry"]);
  
  var submeshes = jsonObj["submeshes"];
  mesh._subMeshes = new List.generate(submeshes.length, (index) {
    var submesh = submeshes[index];
    var sub =  new Mesh();
    
    sub.useSharedVertices = submesh['usesharedvertices'];
    if(!sub.useSharedVertices) {
      sub._geometry = parseGeometry(submesh["geometry"]);
    }
    
    var material = submesh["material"];
    sub._material = new Material();
    sub._material.textureSource = material["texture"];
    sub._material.shader = Shader.simpleShader;
    
    var ambient = material["ambient"];
    sub._material.ambient = new List.generate(ambient.length, (i) {
      return ambient[i].toDouble();
    });

    var diffuse = material["diffuse"];
    sub._material.diffuse = new List.generate(diffuse.length, (i) {
      return diffuse[i].toDouble();
    });
    
    var specular = material["specular"];
    sub._material.specular = new List.generate(specular.length, (i) {
      return specular[i].toDouble();
    });
    
    var emissive = material["emissive"];
    sub._material.emissive = new List.generate(emissive.length, (i) {
      return emissive[i].toDouble();
    });
    
    var faces = submesh["faces"];
    sub._faces = new List.generate(faces.length, (i) {
      return faces[i].toInt();
    });
    return sub;
  });
  
  return mesh;
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





















