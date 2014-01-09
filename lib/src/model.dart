part of orange;




class ModelVertexFormat {
  static const Position = 0x0001;
  static const UV = 0x0002;
  static const UV2 = 0x0004;
  static const Normal = 0x0008;
  static const Tangent = 0x0010;
  static const Color = 0x0020;
  static const BoneWeights = 0x0040;
}

Shader modelShader;
Shader lightmapShader;
Matrix4 identityMat = new Matrix4.identity();

String getLumpId(id) {
  return new String.fromCharCodes([id & 0xff,
                                   (id >> 8) & 0xff,
                                   (id >> 16) & 0xff,
                                   (id >> 24) & 0xff]);
}

class Model {
  static List<Model> _instances = [];
  
  int vertexFormat = 0;
  int vertexStride = 0;
  gl.Buffer vertexBuffer;
  gl.Buffer indexBuffer;
  List<Mesh> meshes = [];
  int _visibleFlag = -1;
  bool complete = false;
  Matrix4 matrix = new Matrix4.identity();
  Lightmap lightmap;
  
  Future<Model> load(gl.RenderingContext ctx, String url) {
    var completer = new Completer();
    var vertComplete = false, modelComplete = false;
    html.HttpRequest.request("$url.wglvert", responseType: "arraybuffer").then((r){
      var bytes = _parseBinary(r.response);
      _compileBuffers(ctx, bytes);
      vertComplete = true;
      if(modelComplete) {
        complete = true;
        completer.complete(this);
      }
    });
    html.HttpRequest.request("$url.wglmodel").then((r){
      var model = JSON.decode(r.response);
      _parseModel(model);
      _compileMaterials(ctx, meshes);
      modelComplete = true;
      if(vertComplete) {
        complete = true;
        completer.complete(this);
      }
    });
    return completer.future;
  }
  
  _parseBinary(Object buffer) {
    var vertexArray, indexArray;
    var header = new Uint32List.view(buffer, 0, 3);
    if(getLumpId(header[0]) != "wglv") {
      throw new ArgumentError("Binary file magic number does not match expected value.");
    }
    if(header[1] > 1) {
      throw new ArgumentError("Binary file version is not supported.");
    }
    var lumpCount = header[2];
    header = new Uint32List.view(buffer, 12, lumpCount * 3);
    for(var i = 0; i < lumpCount; i++) {
      var lumpId = getLumpId(header[i * 3]);
      var offset = header[(i * 3) + 1];
      var length = header[(i * 3) + 2];
      switch(lumpId) {
        case "vert":
          vertexArray = _parseVert(buffer, offset, length);
          break;
        case "indx":
          indexArray = _parseIndex(buffer, offset, length);
          break;
      }
    }
    return {"vertex": vertexArray, "index": indexArray};
  }
  
  _parseVert(Object buffer, int offset, int length) {
    var header = new Uint32List.view(buffer, offset, 2);
    vertexFormat = header[0];
    vertexStride = header[1];
    return new Uint8List.view(buffer, offset + 8, length - 8);
  }
  
  _parseIndex(Object buffer, int offset, int length) {
    return new Uint16List.view(buffer, offset, length ~/ 2);
  }
  
  _compileBuffers(gl.RenderingContext ctx, dynamic bytes) {
    vertexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    ctx.bufferDataTyped(gl.ARRAY_BUFFER, bytes["vertex"], gl.STATIC_DRAW);
    
    indexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, bytes["index"], gl.STATIC_DRAW);
  }
  
  _parseModel(Map doc) {
    meshes = []; 
    doc["meshes"].forEach((v) {
      var mesh = new Mesh();
      mesh.defaultTexture = v["defaultTexture"];
      mesh.material = v["material"];
      v["submeshes"].forEach((sv) {
        var subMesh = new Mesh();
        subMesh.boneCount = sv["boneCount"];
        subMesh.boneOffset = sv["boneOffset"];
        subMesh.indexCount = sv["indexCount"];
        subMesh.indexOffset = sv["indexOffset"];
        mesh.subMeshes.add(subMesh);
      });
      meshes.add(mesh);
    });
  }
  
  _compileMaterials(gl.RenderingContext ctx, List<Mesh> meshes) {
    var textureManager = new TextureManager();
    meshes.forEach((mesh) {
      textureManager.load(ctx, mesh.defaultTexture).then((t) => mesh.diffuse = t);
    });
  }
  
  Model() {
    _instances.add(this);
  }
  
  destroy() {
    _instances.remove(this);
  }
  
  bindBuffer(gl.RenderingContext ctx, Shader shader) {
    var offset = 0, format = vertexFormat, stride = vertexStride;
    
    ctx.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    
    var positionAttrib = shader.attributes["position"];
    ctx.enableVertexAttribArray(positionAttrib.location);
    ctx.vertexAttribPointer(positionAttrib.location, 3, gl.FLOAT, false, stride, 0);
    offset = 12;
    
    if(format & ModelVertexFormat.UV > 0) {
      if(shader.attributes.containsKey("texture")) {
        var textureAttrib = shader.attributes["texture"];
        ctx.enableVertexAttribArray(textureAttrib.location);
        ctx.vertexAttribPointer(textureAttrib.location, 2, gl.FLOAT, false, stride, offset);
      }
      offset += 8;
    }
    
    if(format & ModelVertexFormat.UV2 > 0) {
      if(shader.attributes.containsKey("texture2")) {
        var textureAttrib = shader.attributes["texture2"];
        ctx.enableVertexAttribArray(textureAttrib.location);
        ctx.vertexAttribPointer(textureAttrib.location, 2, gl.FLOAT, false, stride, offset);
      }
      offset += 8;
    }
    
    if(format & ModelVertexFormat.Normal > 0) {
      if(shader.attributes.containsKey("normal")) {
        var normalAttrib = shader.attributes["normal"];
        ctx.enableVertexAttribArray(normalAttrib.location);
        ctx.vertexAttribPointer(normalAttrib.location, 3, gl.FLOAT, false, stride, offset);
      }
      offset += 12;
    }
    
    if(format & ModelVertexFormat.Tangent > 0) {
      if(shader.attributes.containsKey("tangent")) {
        var tangentAttrib = shader.attributes["tangent"];
        ctx.enableVertexAttribArray(tangentAttrib.location);
        ctx.vertexAttribPointer(tangentAttrib.location, 3, gl.FLOAT, false, stride, offset);
      }
      offset += 12;
    }
    
    if(format & ModelVertexFormat.Color > 0) {
      if(shader.attributes.containsKey("color")) {
        var colorAttrib = shader.attributes["color"];
        ctx.enableVertexAttribArray(colorAttrib.location);
        ctx.vertexAttribPointer(colorAttrib.location, 4, gl.UNSIGNED_BYTE, false, stride, offset);
      }
      offset += 4;
    }
    
    if(format & ModelVertexFormat.BoneWeights > 0) {
      if(shader.attributes.containsKey("weights") && shader.attributes.containsKey("bones")) {
        var weightsAttrib = shader.attributes["weights"];
        var bonesAttrib = shader.attributes["bones"];
        ctx.enableVertexAttribArray(weightsAttrib.location);
        ctx.enableVertexAttribArray(bonesAttrib.location);
        ctx.vertexAttribPointer(weightsAttrib.location, 3, gl.FLOAT, false, stride, offset);
        ctx.vertexAttribPointer(bonesAttrib.location, 3, gl.FLOAT, false, stride, offset + 12);
      }
    }
  }
  
  draw(gl.RenderingContext ctx, Matrix4 viewMatrix, Matrix4 projectionMatrix) {
    if(complete == false)
      return;
    
    if(modelShader == null) {
      modelShader = new Shader(ctx, modelVS, modelFS);
    }
    var shader = modelShader;
    if(shader.ready == false) {
      return;
    }
    
    ctx.useProgram(shader.program);
    bindBuffer(ctx, shader);
    
    ctx.uniform3f(shader.uniforms["lightPos"].location, 16, -32, 32);
    ctx.uniformMatrix4fv(shader.uniforms["viewMat"].location, false, viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["modelMat"].location, false, or(matrix, identityMat).storage);
    ctx.uniformMatrix4fv(shader.uniforms["projectionMat"].location, false, projectionMatrix.storage);
    
    meshes.forEach((mesh) {
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(gl.TEXTURE_2D, mesh.diffuse);
      ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
      mesh.subMeshes.forEach((subMesh) {
        ctx.drawElements(gl.TRIANGLES, subMesh.indexCount, gl.UNSIGNED_SHORT, subMesh.indexOffset * 2);
      });
      
    });
  }
  
  drawInstances(gl.RenderingContext ctx, Matrix4 viewMatrix, Matrix4 projectionMatrix, int visibileFlag) {
    if(complete == false) {
      return;
    }
    
    if(_visibleFlag > 0 && _visibleFlag < visibileFlag) {
      return;
    }
    if(modelShader == null) {
      modelShader = new Shader(ctx, modelVS, modelFS);
    }
    var shader = modelShader;
    if(shader.ready == false) {
      return;
    }
    
    ctx.useProgram(shader.program);
    bindBuffer(ctx, shader);
    
    ctx.uniform3f(shader.uniforms["lightPos"].location, 16, -32, 32);
    ctx.uniformMatrix4fv(shader.uniforms["viewMat"].location, false, viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["projectionMat"].location, false, projectionMatrix.storage);
    ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
    meshes.forEach((mesh) {
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(gl.TEXTURE_2D, mesh.diffuse);
      mesh.subMeshes.forEach((subMesh) {
        _instances.forEach((instance) {
          if(instance._visibleFlag < 0 || instance._visibleFlag >= visibileFlag) {
            ctx.uniformMatrix4fv(shader.uniforms["modelMat"].location, false, instance.matrix.storage);
            ctx.drawElements(gl.TRIANGLES, subMesh.indexCount, gl.UNSIGNED_SHORT, subMesh.indexOffset * 2);
          }
        });
      });
    });
  }
  
  drawLightmappedInstances(gl.RenderingContext ctx, Matrix4 viewMatrix, Matrix4 projectionMatrix, lightmaps, visibileFlag) {
    if(complete == false) {
      return;
    }
    if(_visibleFlag > 0 && _visibleFlag < visibileFlag) {
      return;
    }
    if(lightmapShader == null) {
      lightmapShader = new Shader(ctx, lightmapVS, lightmapFS);
    }
    var shader = lightmapShader;
    if(shader.ready == false) {
      return;
    }
    
    ctx.useProgram(shader.program);
    bindBuffer(ctx, shader);
    ctx.uniformMatrix4fv(shader.uniforms["viewMat"].location, false, viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["projectionMat"].location, false, projectionMatrix.storage);
    ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
    ctx.uniform1i(shader.uniforms["lightmap"].location, 1);
    
    meshes.forEach((mesh) {
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(gl.TEXTURE_2D, mesh.diffuse);
      
      mesh.subMeshes.forEach((subMesh) {
        _instances.forEach((instance) {
          if(instance._visibleFlag < 0 || instance._visibleFlag >= visibileFlag) {
            ctx.activeTexture(gl.TEXTURE1);
            ctx.bindTexture(gl.TEXTURE_2D, lightmaps[instance.lightmap.id]);
            ctx.uniform2fv(shader.uniforms["lightmapScale"].location, instance.lightmap.scale);
            ctx.uniform2fv(shader.uniforms["lightmapOffset"].location, instance.lightmap.offset);
            ctx.uniformMatrix4fv(shader.uniforms["modelMat"].location, false, instance.matrix);
            ctx.drawElements(gl.TRIANGLES, subMesh.indexCount, gl.UNSIGNED_SHORT, subMesh.indexOffset * 2);
          }
        });
      });
    });
  }
  
  updateVisibility(int flag) {
    _visibleFlag = flag;
  }
}





































