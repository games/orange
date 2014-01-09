part of orange;



// http://blog.tojicode.com/2011/10/building-game-part-2-model-format.html


class ModelVertexFormat {
  static const Position = 0x0001;
  static const UV = 0x0002;
  static const UV2 = 0x0004;
  static const Normal = 0x0008;
  static const Tangent = 0x0010;
  static const Color = 0x0020;
  static const BoneWeights = 0x0040;
}

String _getLumpId(id) {
  return new String.fromCharCodes([id & 0xff,
                                   (id >> 8) & 0xff,
                                   (id >> 16) & 0xff,
                                   (id >> 24) & 0xff]);
}


class WglLoader {
  
  Node _model;
  bool _skinned;
  
  Future<Node> load(gl.RenderingContext ctx, String url) {
    _model = new Node();
    _skinned = false;
    var completer = new Completer();
    Future.wait([html.HttpRequest.request("$url.wglvert", responseType: "arraybuffer"),
                 html.HttpRequest.request("$url.wglmodel")])
           .then((responses) {
                   _compileBuffers(ctx, _parseBinary(responses[0].response));
                   _parseModel(ctx, JSON.decode(responses[1].response));
                   completer.complete(_model);
                 });
    return completer.future;
  }
  
  _parseBinary(ByteBuffer buffer) {
    var vertexArray, indexArray;
    var header = new Uint32List.view(buffer, 0, 3);
    if(_getLumpId(header[0]) != "wglv") {
      throw new ArgumentError("Binary file magic number does not match expected value.");
    }
    if(header[1] > 1) {
      throw new ArgumentError("Binary file version is not supported.");
    }
    var lumpCount = header[2];
    header = new Uint32List.view(buffer, 12, lumpCount * 3);
    for(var i = 0; i < lumpCount; i++) {
      var lumpId = _getLumpId(header[i * 3]);
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
  
  _parseVert(ByteBuffer buffer, int offset, int length) {
    var header = new Uint32List.view(buffer, offset, 2);
    var format = header[0], stride = header[1];
    var byteOffset = 0;
    _model.attributes = {};
    _model.attributes[Semantics.position] = new MeshAttribute(3, gl.FLOAT, stride, byteOffset);
    byteOffset = 12;
    if(format & ModelVertexFormat.UV > 0) {
      _model.attributes[Semantics.texture] = new MeshAttribute(2, gl.FLOAT, stride, byteOffset);
      byteOffset += 8;
    }
    if(format & ModelVertexFormat.UV2 > 0) {
      _model.attributes[Semantics.texture2] = new MeshAttribute(2, gl.FLOAT, stride, byteOffset);
      byteOffset += 8;
    }
    if(format & ModelVertexFormat.Normal > 0) {
      _model.attributes[Semantics.normal] = new MeshAttribute(3, gl.FLOAT, stride, byteOffset);
      byteOffset += 12;
    }
    if(format & ModelVertexFormat.Tangent > 0) {
      _model.attributes[Semantics.tangent] = new MeshAttribute(3, gl.FLOAT, stride, byteOffset);
      byteOffset += 12;
    }
    if(format & ModelVertexFormat.Color > 0) {
      _model.attributes[Semantics.color] = new MeshAttribute(4, gl.UNSIGNED_BYTE, stride, byteOffset);
//      offset += 4;
    } 
    // FIXME: this is a bug. 
    byteOffset += 4;
    if(format & ModelVertexFormat.BoneWeights > 0) {
      _model.attributes[Semantics.weights] = new MeshAttribute(3, gl.FLOAT, stride, byteOffset);
      _model.attributes[Semantics.bones] = new MeshAttribute(3, gl.FLOAT, stride, byteOffset + 12);
      _skinned = true;
    }
    return new Uint8List.view(buffer, offset + 8, length - 8);
  }
  
  _parseIndex(Object buffer, int offset, int length) {
    return new Uint16List.view(buffer, offset, length ~/ 2);
  }
  
  _compileBuffers(gl.RenderingContext ctx, Map buffers) {
    _model.vertexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ARRAY_BUFFER, _model.vertexBuffer);
    ctx.bufferDataTyped(gl.ARRAY_BUFFER, buffers["vertex"], gl.STATIC_DRAW);
    
    _model.indexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _model.indexBuffer);
    ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, buffers["index"], gl.STATIC_DRAW);
  }
  
  _parseModel(gl.RenderingContext ctx, Map description) {
    var textureManager = new TextureManager();
    _model.meshes = []; 
    description["meshes"].forEach((Map v) {
      var mesh = new Mesh();
      textureManager.load(ctx, v["defaultTexture"]).then((t) => mesh.diffuse = t);
      mesh.material = v["material"];
      if(v.containsKey("submeshes")) {
        v["submeshes"].forEach((sv) {
          var subMesh = new Mesh();
          subMesh.jointCount = sv["boneCount"];
          subMesh.jointOffset = sv["boneOffset"];
          subMesh.indicesAttrib = new MeshAttribute(2, gl.UNSIGNED_SHORT, 0, sv["indexOffset"] * 2, sv["indexCount"]);
          mesh.subMeshes.add(subMesh);
        });
      }
      _model.meshes.add(mesh);
    });
    if(_skinned) {
      _model.skeleton = new Skeleton();
      _model.skeleton.jointMatrices = new Float32List(16 * MAX_BONES_PER_MESH);
      _model.skeleton.joints = [];
      var jointsDesc = or(description["bones"], []);
      jointsDesc.forEach((jointDesc) {
        var joint = new Joint();
        joint.name = jointDesc["name"];
        joint.parent = jointDesc["parent"];
        joint.skinned = jointDesc["skinned"];
        joint.pos = new Vector3.fromList(jointDesc["pos"]);
        joint.rot = new Quaternion.fromList(jointDesc["rot"]);
        joint.bindPoseMat = new Matrix4.fromList(jointDesc["bindPoseMat"]);
        joint.jointMat = new Matrix4.identity();
        if(joint.parent == -1) {
          joint.worldPos = joint.pos;
          joint.worldRot = joint.rot;
        } else {
          joint.worldPos = new Vector3.zero();
          joint.worldRot = new Quaternion.identity();
        }
        _model.skeleton.joints.add(joint);
      });
    }
  }
}