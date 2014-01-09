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

String getLumpId(id) {
  return new String.fromCharCodes([id & 0xff,
                                   (id >> 8) & 0xff,
                                   (id >> 16) & 0xff,
                                   (id >> 24) & 0xff]);
}


class WglLoader {
  
  Model _model;
  
  Future<Model> load(gl.RenderingContext ctx, String url) {
    _model = new Model();
    var completer = new Completer();
    Future.wait([html.HttpRequest.request("$url.wglvert", responseType: "arraybuffer"),
                 html.HttpRequest.request("$url.wglmodel")])
           .then((responses) {
                   _compileBuffers(ctx, _parseBinary(responses[0].response));
                   _parseModel(JSON.decode(responses[1].response));
                   _compileMaterials(ctx);
                   completer.complete(_model);
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
    _model.vertexFormat = header[0];
    _model.vertexStride = header[1];
    return new Uint8List.view(buffer, offset + 8, length - 8);
  }
  
  _parseIndex(Object buffer, int offset, int length) {
    return new Uint16List.view(buffer, offset, length ~/ 2);
  }
  
  _compileBuffers(gl.RenderingContext ctx, dynamic bytes) {
    _model.vertexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ARRAY_BUFFER, _model.vertexBuffer);
    ctx.bufferDataTyped(gl.ARRAY_BUFFER, bytes["vertex"], gl.STATIC_DRAW);
    
    _model.indexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _model.indexBuffer);
    ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, bytes["index"], gl.STATIC_DRAW);
  }
  
  _parseModel(Map doc) {
    _model.meshes = []; 
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
      _model.meshes.add(mesh);
    });
    if(_model.vertexFormat & ModelVertexFormat.BoneWeights > 0) {
      _model._skeleton = new Skeleton();
      _model._skeleton.boneMatrices = new Float32List(16 * MAX_BONES_PER_MESH);
      _model._skeleton.bones = [];
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
        _model._skeleton.bones.add(bone);
      });
    }
  }
  
  _compileMaterials(gl.RenderingContext ctx) {
    var textureManager = new TextureManager();
    _model.meshes.forEach((mesh) {
      textureManager.load(ctx, mesh.defaultTexture).then((t) => mesh.diffuse = t);
    });
  }
  
}