part of orange;



class GltfLoader {
  gl.RenderingContext _ctx;
  PolygonMesh _root;
  Uri _uri;
  Map<String, dynamic> _resources;
  Map<String, Joint> _joints;
  Map<String, List<String>> _childrenOfNode;
  Map<String, List<String>> _jointsOfSkeleton;

  Future<Mesh> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _root = new PolygonMesh();
    _root.geometry = new Geometry();
    _resources = {};
    _joints = {};
    _childrenOfNode = {};
    _jointsOfSkeleton = {};
    var completer = new Completer();
    html.HttpRequest.getString(url).then((rsp) {
      var json = JSON.decode(rsp);
      var loadBufferFutures = [];
      json["buffers"].forEach((k, v) => loadBufferFutures.add(_loadBuffer(k, v)));
      Future.wait(loadBufferFutures).then((List buffers) {
        // TODO remove mirror
        InstanceMirror mirror = reflect(this);
        var categories = ["bufferViews", "images", "samplers", "textures", "materials", "attributes", "indices", "accessors", "meshes", "skins", "nodes", "scenes"];
        categories.forEach((cat) {
          var description = json[cat];
          if (description != null) mirror.invoke(new Symbol("handle${capitalize(cat)}"), [description]);
        });
        completer.complete(_root);
      });
    }).catchError((Error e) => print([e, e.stackTrace]));
    return completer.future;
  }

  _loadBuffer(String name, Map doc) {
    var completer = new Completer();
    html.HttpRequest.request(_uri.resolve(doc["path"]).toString(), responseType: "arraybuffer").then((response) {
      doc["name"] = name;
      doc["data"] = response.response;
      _resources[name] = doc;
      completer.complete(doc);
    });
    return completer.future;
  }

  handleBufferViews(Map doc) {
    doc.forEach((k, v) {
      var buffer = _resources[v["buffer"]]["data"];
      var target = _ensureType(v["target"]);
      if (target == gl.ARRAY_BUFFER) {
        var vert = new Float32List.view(buffer, v["byteOffset"], v["byteLength"] ~/ 4);
        v["data"] = vert;
//        _root.setVertices(vert);
        //        _root.mesh.vertexBuffer = _ctx.createBuffer();
        //        _ctx.bindBuffer(gl.ARRAY_BUFFER, _root.mesh.vertexBuffer);
        //        _ctx.bufferDataTyped(gl.ARRAY_BUFFER, vert, gl.STATIC_DRAW);
      } else if (target == gl.ELEMENT_ARRAY_BUFFER) {
        var idx = new Uint16List.view(buffer, v["byteOffset"], v["byteLength"] ~/ 2);
        v["data"] = idx;
//        _root.setFaces(idx);
        //        _root.mesh.indexBuffer = _ctx.createBuffer();
        //        _ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _root.mesh.indexBuffer);
        //        _ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, idx, gl.STATIC_DRAW);
      } else {
        v["data"] = new Float32List.view(buffer, v["byteOffset"], v["byteLength"] ~/ 4);
      }
      _resources[k] = v;
    });
  }

  handleImages(Map doc) {
    doc.forEach((k, v) => _resources[k] = v);
  }

  handleSamplers(Map doc) {
    doc.forEach((k, v) {
      var sampler = new Sampler();
      sampler.magFilter = _ensureType(v["magFilter"]);
      sampler.minFilter = _ensureType(v["minFilter"]);
      sampler.wrapS = _ensureType(v["wrapS"]);
      sampler.wrapT = _ensureType(v["wrapT"]);
      _resources[k] = sampler;
    });
  }

  handleTextures(Map description) {
    description.forEach((k, v) {
      v["path"] = _uri.resolve(_resources[v["source"]]["path"]).toString();
      v["sampler"] = _resources[v["sampler"]];
      v["format"] = _ensureType(v["format"]);
      v["internalFormat"] = _ensureType(v["internalFormat"]);
      v["target"] = _ensureType(v["target"]);
      _resources[k] = v;
    });
  }

  handleMaterials(Map description) {
    description.forEach((k, v) {
      //TODO : because the dota2 model from {qtel} is old version.
      var diffuse;
      var values = v["instanceTechnique"]["values"];
      if (values is List) {
        diffuse = values.firstWhere((e) => e["parameter"] == "diffuse");
        diffuse = diffuse != null ? diffuse["value"] : null;
      } else {
        diffuse = values["diffuse"];
      }
      v["diffuse"] = _resources[diffuse];
      _resources[k] = v;
    });
  }

  handleAttributes(description) => handleAccessors(description);
  handleIndices(description) => handleAccessors(description);

  handleAccessors(description) {
    description.forEach((k, v) {
      v["type"] = _ensureType(v["type"]);
      _resources[k] = v;
    });
  }

  handleMeshes(Map description) {
    var once = false;
    var arr = [];

    description.forEach((k, v) {
      var textureManager = new TextureManager();
      var mesh = new Mesh();
      mesh.name = v["name"];
      var primitives = v["primitives"];
      mesh.children = new List.generate(primitives.length, (i) {
        var p = primitives[i];
        var indicesAttrib = _resources[p["indices"]];
        var primitiveType = p["primitive"];
        var attributes = p["attributes"];
        if (attributes == null) {
          attributes = p["semantics"];
        }

        var submesh = new PolygonMesh();
        submesh.material = new StandardMaterial();

        var material = _resources[p["material"]];
        textureManager.load(_ctx, material["diffuse"]).then((t) => submesh.material.diffuseTexture = t);
        //        submesh.indicesAttrib = new BufferView(2, gl.UNSIGNED_SHORT, 0, indicesAttrib["byteOffset"], indicesAttrib["count"]);
        submesh.faces = new BufferView(2, gl.UNSIGNED_SHORT, 0, indicesAttrib["byteOffset"], count: indicesAttrib["count"], target: gl.ELEMENT_ARRAY_BUFFER);
        //        submesh.attributes = {};

        attributes.forEach((ak, av) {
          var accessor = _resources[av];
          var bufferView = _resources[accessor["bufferView"]];
          var byteOffset = accessor["byteOffset"];
          var size = accessor["byteStride"] ~/ 4;
          submesh.geometry.buffers[_convertSemantics(ak)] = new BufferView(size, gl.FLOAT, 0, byteOffset);

          if (ak == "WEIGHT") {
            var view = new Float32List.view(bufferView["data"].buffer, byteOffset, indicesAttrib["count"]);
            if (view != null) {
              var vv = view.length;
            }
          }

        });
        return submesh;
      }, growable: false);

      print(arr.join("\r\n"));
      _resources[k] = mesh;
    });
  }

  handleSkins(Map description) {
    description.forEach((k, v) {
      List joints = v["joints"];
      var skeleton = new Skeleton();
      skeleton.name = k;
      skeleton.jointMatrices = new Float32List(16 * joints.length);
      skeleton.joints = [];
      //      skeleton.bindShapeMatrix = new Matrix4.fromList(v["bindShapeMatrix"]);
      v["skeleton"] = skeleton;
      _jointsOfSkeleton[k] = joints;
      _resources[k] = v;
    });
  }

  handleNodes(Map description) {
    description.forEach((String k, Map v) {
      var matrix;
      if (v.containsKey("matrix")) {
        matrix = _mat4FromList(v["matrix"]);
      } else {
        matrix = _newMatrix4FromSQT(v["scale"], v["rotation"], v["translation"]);
      }
      var node, mesh;
      if (v.containsKey("jointId")) {
        node = new Joint();
        node.name = v["jointId"];
        _joints[node.name] = node;
      } else if (v.containsKey("light")) {
        return;
      } else if (v.containsKey("camera")) {
        return;
      } else {
        node = new Mesh();
        node.name = v["name"];
        if (v.containsKey("meshes")) {
          var meshes = v["meshes"];
          mesh = new Mesh();
          mesh.children = new List.generate(meshes.length, (i) {
            return _resources[meshes[i]];
          }, growable: false);
        } else if (v.containsKey("mesh")) {
          mesh = new Mesh();
          mesh.children = [_resources[v["mesh"]]];
        } else if (v.containsKey("instanceSkin")) {
          var instanceSkin = v["instanceSkin"];
          node.skeleton = _resources[instanceSkin["skin"]]["skeleton"];
          var source = instanceSkin["sources"];
          mesh = new Mesh();
          mesh.children = new List.generate(source.length, (i) {
            var m = _resources[source[i]];
            m.skeleton = node.skeleton;
            m.jointOffset = 0;
            m.jointCount = _jointsOfSkeleton[node.skeleton.name].length;
            return m;
          }, growable: false);
        }
      }
      if (mesh != null) {
        node = mesh;
      }
      node.applyMatrix(matrix);
      _childrenOfNode[node.name] = v["children"];
      _resources[k] = node;
    });
  }

  handleScenes(Map description) {
    var json = description.values.first;
    json["nodes"].forEach((name) {
      var node = _resources[name];
      if (node != null && !(node is Joint)) {
        _root.add(node);
      }
    });

    //    _root.mesh.material = new Material();
    //    _root.mesh.material.pass = new Pass();
    //    if(_root.skeleton != null) {
    //      _root.mesh.material.pass.shader = new Shader(_ctx, skinnedModelVS, skinnedModelFS);
    //    } else {
    //      _root.mesh.material.pass.shader = new Shader(_ctx, modelVS, modelFS);
    //    }
    //    _root.mesh.subMeshes.forEach((m) => m.material = _root.mesh.material);

    _root.children.forEach((node) => _buildNodeHierarchy(node));
    _buildSkins(_root);
    _root.updateMatrix();
  }

  _buildNodeHierarchy(Node node) {
    if (node.children == null) node.children = new List();
    var childNames = _childrenOfNode[node.name];
    childNames.forEach((name) {
      var child = _resources[name];
      node.add(child);
      _buildNodeHierarchy(child);
    });
  }

  _buildSkins(Node node) {
    if (node is Mesh && node.skeleton != null) {
      var skin = _resources[node.skeleton.name];
      node.skeleton.joints = [];
      var jointsNames = _jointsOfSkeleton[node.skeleton.name];
      jointsNames.forEach((jointName) {
        var joint = _joints[jointName];
        node.skeleton.joints.add(joint);
      });

      var invBindMatAttri = skin["inverseBindMatrices"];
      var bufferView = _resources[invBindMatAttri["bufferView"]];
      var buffer = bufferView["data"];
      var jointCount = node.skeleton.joints.length;
      for (var i = 0; i < jointCount; i++) {
        var joint = node.skeleton.joints[i];
        var inverseBindMatrix = new Matrix4.identity();
        for (var j = 0; j < 16; j++) {
          inverseBindMatrix[j] = buffer[(i * 16) + j];
        }
        // outv :
        //  for 0 -> n:
        //    outv += ((((v * BSM) * IMBi) * JMi) * JW)
        //
        // n: number of joints that influence vertex v
        // BSM: bind shape matrix
        // IBMi: inverse bind matrix of joint i
        // JMi: joint matrix of joint i
        // JW: joint weight/influence of joint i on vertex v
        joint._inverseBindMatrix = inverseBindMatrix;
        //        joint.jointMat = inverseBindMatrix;
      }
    }
    node.children.forEach((child) => _buildSkins(child));
  }

}



Matrix4 _newMatrix4FromSQT(List s, List r, List t) {
  var m = new Matrix4.zero();
  m.setFromTranslationRotation(new Vector3.fromFloat32List(new Float32List.fromList(t)), new Quaternion.fromFloat32List(new Float32List.fromList(r)));
  m.scale(s[0].toDouble(), s[1].toDouble(), s[2].toDouble());
  return m;
}



Matrix4 _mat4FromList(List l) {
  var tl = new Float32List(l.length);
  for (var i = 0; i < l.length; i++) {
    tl[i] = l[i].toDouble();
  }
  return new Matrix4.fromFloat32List(tl);
}

String _convertSemantics(String name) {
  return {
    "NORMAL": Semantics.normal,
    "POSITION": Semantics.position,
    "TEXCOORD_0": Semantics.texture,
    "WEIGHT": Semantics.weights,
    "JOINT": Semantics.joints,
  }[name];
}


_ensureType(type) {
  if (type is num) {
    return type;
  } else {
    switch (type) {
      case "FLOAT":
        return gl.FLOAT;
      case "FLOAT_VEC2":
        return gl.FLOAT_VEC2;
      case "FLOAT_VEC3":
        return gl.FLOAT_VEC3;
      case "FLOAT_VEC4":
        return gl.FLOAT_VEC4;
      case "FLOAT_MAT2":
        return gl.FLOAT_MAT2;
      case "FLOAT_MAT3":
        return gl.FLOAT_MAT3;
      case "FLOAT_MAT4":
        return gl.FLOAT_MAT4;
      case "UNSIGNED_BYTE":
        return gl.UNSIGNED_BYTE;
      case "UNSIGNED_INT":
        return gl.UNSIGNED_INT;
      case "UNSIGNED_SHORT":
        return gl.UNSIGNED_SHORT;
      case "LINEAR":
        return gl.LINEAR;
      case "LINEAR_MIPMAP_LINEAR":
        return gl.LINEAR_MIPMAP_LINEAR;
      case "RGBA":
        return gl.RGBA;
      case "TEXTURE_2D":
        return gl.TEXTURE_2D;
      case "REPEAT":
        return gl.REPEAT;
      case "ARRAY_BUFFER":
        return gl.ARRAY_BUFFER;
      case "ELEMENT_ARRAY_BUFFER":
        return gl.ELEMENT_ARRAY_BUFFER;
      default:
        return 0;
    }
  }
}























