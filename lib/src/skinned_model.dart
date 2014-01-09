part of orange;


Shader skinnedModelShader;

class SkinnedModel extends Model {
  List<Bone> bones;
  Float32List boneMatrices;
  bool _dirtyBones = true;
  
  Future<SkinnedModel> load(gl.RenderingContext ctx, String url) {
    return super.load(ctx, url);
  }
  
  _parseBinary(Object buffer) {
    var result = super._parseBinary(buffer);
    if(vertexFormat & ModelVertexFormat.BoneWeights > 0) {
      boneMatrices = new Float32List(16 * MAX_BONES_PER_MESH);
    }
    return result;
  }
  
  _parseModel(Map doc) {
    super._parseModel(doc);
    
    bones = [];
    var boneDesc = or(doc["bones"], []);
    boneDesc.forEach((boneDesc) {
      var bone = new Bone();
      bone.name = boneDesc["name"];
      bone.parent = boneDesc["parent"];
      bone.skinned = boneDesc["skinned"];
      bone.pos = new Vector3.fromList(boneDesc["pos"]);
      bone.rot = new Quaternion.fromList(boneDesc["rot"]);
      bone.bindPoseMat = new Matrix4.fromList(boneDesc["bindPoseMat"]);
      bone.boneMat = new Matrix4.identity();
      if(bone.parent == -1) {
        bone.worldPos = bone.pos;
        bone.worldRot = bone.rot;
      } else {
        bone.worldPos = new Vector3.zero();
        bone.worldRot = new Quaternion.identity();
      }
      bones.add(bone);
    });
  }
  
  draw(gl.RenderingContext ctx, Matrix4 viewMatrix, Matrix4 projectionMatrix) {
    if(complete == false) {
      return; 
    }
    
    if(skinnedModelShader == null) {
      skinnedModelShader = new Shader(ctx, skinnedModelVS, skinnedModelFS);
    }
    var shader = skinnedModelShader;
    if(shader.ready == false) {
      return;
    }
    
    ctx.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    
    ctx.useProgram(shader.program);
    ctx.uniform3f(shader.uniforms["lightPos"].location, 16, -32, 32);
    ctx.uniformMatrix4fv(shader.uniforms["viewMat"].location, false, viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["modelMat"].location, false, identityMat.storage);
    ctx.uniformMatrix4fv(shader.uniforms["projectionMat"].location, false, projectionMatrix.storage);
    
    ctx.enableVertexAttribArray(shader.attributes["position"].location);
    ctx.enableVertexAttribArray(shader.attributes["texture"].location);
    ctx.enableVertexAttribArray(shader.attributes["normal"].location);
    ctx.enableVertexAttribArray(shader.attributes["weights"].location);
    ctx.enableVertexAttribArray(shader.attributes["bones"].location);
    
    ctx.vertexAttribPointer(shader.attributes["position"].location, 3, gl.FLOAT, false, vertexStride, 0);
    ctx.vertexAttribPointer(shader.attributes["texture"].location, 2, gl.FLOAT, false, vertexStride, 12);
    ctx.vertexAttribPointer(shader.attributes["normal"].location, 3, gl.FLOAT, false, vertexStride, 20);
    ctx.vertexAttribPointer(shader.attributes["weights"].location, 3, gl.FLOAT, false, vertexStride, 48);
    ctx.vertexAttribPointer(shader.attributes["bones"].location, 3, gl.FLOAT, false, vertexStride, 60);
    
    if(_dirtyBones) {
      for(var i = 0; i < bones.length; i++) {
        var bone = bones[i];
        for(var j = 0; j < bone.boneMat.storage.length; j++) {
          boneMatrices[i * 16 + j] = bone.boneMat[j];
        }
      }
    }
    
    meshes.forEach((mesh) {
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(gl.TEXTURE_2D, mesh.diffuse);
      ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
      mesh.subMeshes.forEach((subMesh) {
        var boneSet = boneMatrices.sublist(subMesh.boneOffset * 16, (subMesh.boneOffset + subMesh.boneCount) * 16);
        ctx.uniformMatrix4fv(shader.uniforms["boneMat"].location, false, boneSet);
        ctx.drawElements(gl.TRIANGLES, subMesh.indexCount, gl.UNSIGNED_SHORT, subMesh.indexOffset * 2);
      });
    });
  }
}





















