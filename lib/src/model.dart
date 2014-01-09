part of orange;





Shader modelShader;
Shader skinnedModelShader;
Shader lightmapShader;
Matrix4 identityMat = new Matrix4.identity();


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
  Skeleton _skeleton;  
  
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
//        ctx.vertexAttribPointer(weightsAttrib.location, 3, gl.FLOAT, false, stride, offset);
        ctx.vertexAttribPointer(weightsAttrib.location, 3, gl.FLOAT, false, stride, 48);
        ctx.vertexAttribPointer(bonesAttrib.location, 3, gl.FLOAT, false, stride, offset + 12);
      }
    }
  }
  
  draw(gl.RenderingContext ctx, Matrix4 viewMatrix, Matrix4 projectionMatrix) {
    Shader shader;
    if(_skeleton != null) {
      if(skinnedModelShader == null) {
        skinnedModelShader = new Shader(ctx, skinnedModelVS, skinnedModelFS);
      }
      shader = skinnedModelShader;
    } else {
      if(modelShader == null) {
        modelShader = new Shader(ctx, modelVS, modelFS);
      }
      shader = modelShader;
    }
    if(shader.ready == false) {
      return;
    }
    
    ctx.useProgram(shader.program);
    bindBuffer(ctx, shader);
    
    ctx.uniform3f(shader.uniforms["lightPos"].location, 16, -32, 32);
    ctx.uniformMatrix4fv(shader.uniforms["viewMat"].location, false, viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["modelMat"].location, false, or(matrix, identityMat).storage);
    ctx.uniformMatrix4fv(shader.uniforms["projectionMat"].location, false, projectionMatrix.storage);
    
    if(_skeleton == null) {
      meshes.forEach((mesh) {
        ctx.activeTexture(gl.TEXTURE0);
        ctx.bindTexture(gl.TEXTURE_2D, mesh.diffuse);
        ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
        mesh.subMeshes.forEach((subMesh) {
          ctx.drawElements(gl.TRIANGLES, subMesh.indexCount, gl.UNSIGNED_SHORT, subMesh.indexOffset * 2);
        });
      });
    } else {
      if(_skeleton._dirtyBones) {
        for(var i = 0; i < _skeleton.bones.length; i++) {
          var bone = _skeleton.bones[i];
          for(var j = 0; j < bone.boneMat.storage.length; j++) {
            _skeleton.boneMatrices[i * 16 + j] = bone.boneMat[j];
          }
        }
      }
      meshes.forEach((mesh) {
        ctx.activeTexture(gl.TEXTURE0);
        ctx.bindTexture(gl.TEXTURE_2D, mesh.diffuse);
        ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
        mesh.subMeshes.forEach((subMesh) {
          var boneSet = _skeleton.boneMatrices.sublist(subMesh.boneOffset * 16, (subMesh.boneOffset + subMesh.boneCount) * 16);
          ctx.uniformMatrix4fv(shader.uniforms["boneMat"].location, false, boneSet);
          ctx.drawElements(gl.TRIANGLES, subMesh.indexCount, gl.UNSIGNED_SHORT, subMesh.indexOffset * 2);
        });
      });
    }
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





































