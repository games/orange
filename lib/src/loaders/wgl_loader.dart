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
  gl.RenderingContext _ctx;
  Node _node;
  int _format;
  int _stride;
  bool _skinned;
  Uri _uri;
  TypedData _vertexArray;
  TypedData _indexArray;
  
  Future<Node> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _node = new Node();
    _node.mesh = new Mesh();
    _skinned = false;
    var completer = new Completer();
    Future.wait([html.HttpRequest.request("$url.wglvert", responseType: "arraybuffer"),
                 html.HttpRequest.request("$url.wglmodel")])
           .then((responses) {
                   _parseBinary(responses[0].response);
                   _compileBuffers(ctx);
                   _parseModel(ctx, JSON.decode(responses[1].response));
                   completer.complete(_node);
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
          _vertexArray = _parseVert(buffer, offset, length);
          break;
        case "indx":
          _indexArray = _parseIndex(buffer, offset, length);
          break;
      }
    }
  }
  
  _parseVert(ByteBuffer buffer, int offset, int length) {
    var header = new Uint32List.view(buffer, offset, 2);
    _format = header[0]; 
    _stride = header[1];
    _skinned = _format & ModelVertexFormat.BoneWeights > 0;
    return new Uint8List.view(buffer, offset + 8, length - 8);
  }
  
  _parseIndex(Object buffer, int offset, int length) {
    return new Uint16List.view(buffer, offset, length ~/ 2);
  }
  
  _compileBuffers(gl.RenderingContext ctx) {
    _node.mesh.vertexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ARRAY_BUFFER, _node.mesh.vertexBuffer);
    ctx.bufferDataTyped(gl.ARRAY_BUFFER, _vertexArray, gl.STATIC_DRAW);
    
    _node.mesh.indexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _node.mesh.indexBuffer);
    ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexArray, gl.STATIC_DRAW);
  }
  
  _parseModel(gl.RenderingContext ctx, Map description) {
    var textureManager = new TextureManager();

    if(_skinned) {
      _node.skeleton = new Skeleton();
      _node.skeleton.jointMatrices = new Float32List(16 * MAX_BONES_PER_MESH);
      _node.skeleton.joints = [];
      var jointsDesc = or(description["bones"], []);
      jointsDesc.forEach((jointDesc) {
        var joint = new Joint();
        joint.name = jointDesc["name"];
        joint.parentId = jointDesc["parent"];
        joint.skinned = jointDesc["skinned"];
        joint.pos = new Vector3.fromList(jointDesc["pos"]);
        joint.rot = new Quaternion.fromList(jointDesc["rot"]);
        joint.bindPoseMat = new Matrix4.fromList(jointDesc["bindPoseMat"]);
        joint.jointMat = new Matrix4.identity();
        if(joint.parentId == -1) {
          joint.worldPos = joint.pos;
          joint.worldRot = joint.rot;
        } else {
          joint.worldPos = new Vector3.zero();
          joint.worldRot = new Quaternion.identity();
        }
        _node.skeleton.joints.add(joint);
      });
    }
    
    _node.mesh = new Mesh();
    description["meshes"].forEach((Map v) {
      var mesh = new Mesh();
      // TODO: maybe there is a bug
      var textureUrl = v["defaultTexture"];
      if(textureUrl == null || textureUrl.isEmpty)
        return;
      textureManager.load(ctx, {"path": _uri.resolve(textureUrl).toString()}).then((t) => mesh.diffuse = t);
//      mesh.material = new Material();
//      mesh.material.pass = new Pass();
//      if(_skinned) {
//        mesh.material.pass.shader = new Shader(_ctx, skinnedModelVS2, skinnedModelFS2);
//      } else {
//        mesh.material.pass.shader = new Shader(_ctx, modelVS, modelFS);
//      }
      if(v.containsKey("submeshes")) {
        v["submeshes"].forEach((sv) {
          var subMesh = new Mesh();
          subMesh.skeleton = _node.skeleton;
          subMesh.jointCount = sv["boneCount"];
          subMesh.jointOffset = sv["boneOffset"];
          var offset = sv["indexOffset"] * 2;
          var count = sv["indexCount"];
          subMesh.indicesAttrib = new MeshAttribute(2, gl.UNSIGNED_SHORT, 0, offset, count);

          var attrib;
          subMesh.attributes = {};
          attrib = new MeshAttribute(3, gl.FLOAT, _stride, offset, count);
          subMesh.attributes[Semantics.position] = attrib;
          offset += 12;
          if(_format & ModelVertexFormat.UV > 0) {
            attrib = new MeshAttribute(2, gl.FLOAT, _stride, offset, count);
            subMesh.attributes[Semantics.texture] = attrib;
            
            offset += 8;
          }
          if(_format & ModelVertexFormat.UV2 > 0) {
            attrib = new MeshAttribute(2, gl.FLOAT, _stride, offset, count);
            subMesh.attributes[Semantics.texture2] = attrib;
            offset += 8;
          }
          if(_format & ModelVertexFormat.Normal > 0) {
            attrib = new MeshAttribute(3, gl.FLOAT, _stride, offset, count);
            subMesh.attributes[Semantics.normal] = attrib;
            offset += 12;
          }
          if(_format & ModelVertexFormat.Tangent > 0) {
            attrib = new MeshAttribute(3, gl.FLOAT, _stride, offset, count);
            subMesh.attributes[Semantics.tangent] = attrib;
            offset += 12;
          }
          if(_format & ModelVertexFormat.Color > 0) {
            attrib = new MeshAttribute(4, gl.UNSIGNED_BYTE, _stride, offset, count);
            subMesh.attributes[Semantics.color] = attrib;
            //indexOffset += 4;
          } 
          // TODO: this is a bug. 
          offset += 4;
          if(_format & ModelVertexFormat.BoneWeights > 0) {
            attrib = new MeshAttribute(3, gl.FLOAT, _stride, offset, count);
            subMesh.attributes[Semantics.weights] = attrib;
            
            attrib = new MeshAttribute(3, gl.FLOAT, _stride, offset + 12, count);
            subMesh.attributes[Semantics.bones] = attrib;
          }
          
          mesh.subMeshes.add(subMesh);
        });
      }
      _node.mesh.subMeshes.add(mesh);
    });
  }
}