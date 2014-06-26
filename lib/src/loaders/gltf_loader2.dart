part of orange;





class GltfLoader2 {
  gl.RenderingContext _ctx;
  Mesh _root;
  Uri _uri;
  Map<String, dynamic> _resources;
  Map<String, Joint> _joints;
  Map<String, List<String>> _childrenOfNode;
  Map<String, List<String>> _jointsOfSkeleton;

  Future<Mesh> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _root = new Mesh();
    _resources = {};
    _joints = {};
    _childrenOfNode = {};
    _jointsOfSkeleton = {};
    var completer = new Completer<Mesh>();
    html.HttpRequest.getString(url).then((rsp) {
      var json = JSON.decode(rsp);
      var loadBufferFutures = [];
      json["buffers"].forEach((k, v) => loadBufferFutures.add(_loadBuffer(k, v)));
      Future.wait(loadBufferFutures).then((List buffers) {
        _parseNodes(json);
        _parseScene(json);
        completer.complete(_root);
      });
    }).catchError((Error e) => print([e, e.stackTrace]));
    return completer.future;
  }

  void _parseScene(Map doc) {
    var scene = doc["scenes"][doc["scene"]];
    var nodes = [];
    scene["nodes"].forEach((String id) {
      var key = "Node_${id}";
      if (_resources.containsKey(key)) {
        nodes.add(_resources[key]);
      }
    });
    nodes.forEach((node) => _buildNodeHierarchy(node));
    if (nodes.length == 1) {
      _root = nodes.first;
    } else {
      nodes.forEach((node) => _root.add(node));
    }
  }

  void _buildNodeHierarchy(Node node) {
    _childrenOfNode[node.name].forEach((id) {
      var child = _resources["Node_${id}"];
      if (child.parent != null) {
        node.add(child.clone());
      } else {
        node.add(child);
      }
      _buildNodeHierarchy(child);
    });
  }

  void _parseNodes(Map doc) {
    var nodes = doc["nodes"];
    nodes.forEach((String id, Map v) {
      var node;
      if (v.containsKey("joint")) {
        return;
      } else if (v.containsKey("light")) {
        return;
      } else if (v.containsKey("camera")) {
        return;
      } else if (v.containsKey("meshes")) {
        node = new Mesh(name: id);
        v["meshes"].forEach((m) {
          node.add(_getMesh(doc, m));
        });
      } else if (v.containsKey("instanceSkin")) {
        node = new Mesh(name: id);
        // TODO
      } else {
        node = new Mesh(name: id);
      }
      if (v.containsKey("matrix")) {
        node.applyMatrix(_newMatrix4FromList(v["matrix"]));
      } else if (v.containsKey("translation")) {
        node.applyMatrix(_newMatrix4FromSQT(v["scale"], v["rotation"], v["translation"]));
      }
      if (v.containsKey("children")) {
        _childrenOfNode[node.name] = v["children"];
      }
      _resources["Node_${node.name}"] = node;
    });
  }

  Node _getMesh(Map doc, String id) {
    var key = "Mesh_${id}";
    if (_resources.containsKey(key)) {
      return _resources[key].clone();
    } else {
      var m = doc["meshes"][id];
      var node = new Node(name: id);
      m["primitives"].forEach((p) {
        var child = new Mesh();
        child._geometry = new Geometry();
        child.indices = _getAttribute(doc, p["indices"], Semantics.indices);
        p["attributes"].forEach((String at, String ar) {
          if (at == "NORMAL") {
            child._geometry.normals = _getAttribute(doc, ar, Semantics.normal);
          } else if (at == "POSITION") {
            child._geometry.positions = _getAttribute(doc, ar, Semantics.position);
          } else if (at == "TEXCOORD_0") {
            child._geometry.texCoords = _getAttribute(doc, ar, Semantics.texcoords);
          }
        });
        child.material = _getMaterial(doc, p["material"]);
        child.primitive = p["primitive"];
        node.add(child);
      });
      _resources[key] = node;
      return node;
    }
  }

  VertexBuffer _getAttribute(Map doc, String name, String semantics) {
    var key = "VertexBuffer_${name}";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var attr = doc["accessors"][name];
      var view = _getBufferView(doc, attr["bufferView"]);
      var size = 3,
          type = gl.FLOAT,
          stride = attr["byteStride"],
          offset = attr["byteOffset"],
          count = attr["count"];
      switch (attr["type"]) {
        case gl.FLOAT:
          size = 1;
          break;
        case gl.FLOAT_VEC2:
          size = 2;
          break;
        case gl.FLOAT_VEC3:
          size = 3;
          break;
        case gl.FLOAT_VEC4:
          size = 4;
          break;
        case gl.FLOAT_MAT2:
          size = 4;
          break;
        case gl.FLOAT_MAT3:
          size = 9;
          break;
        case gl.FLOAT_MAT4:
          size = 16;
          break;
        case gl.UNSIGNED_SHORT:
          size = 1;
          type = gl.UNSIGNED_SHORT;
          break;
      }
      if (semantics == Semantics.position) {
        // TODO bounding box ?
      }
      var data;
      if (type == gl.FLOAT) {
        data = new Float32List.view(view["data"], view["byteOffset"] + offset, count * size);
      } else {
        data = new Uint16List.view(view["data"], view["byteOffset"] + offset, count);
      }
      var vertexBuffer = new VertexBuffer(size, type, 0, 0, count: count, data: data, target: view["target"]);
      _resources[key] = vertexBuffer;
      return vertexBuffer;
    }
  }

  Map _getBufferView(Map doc, String name) {
    var key = "BufferView_${name}";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var bv = doc["bufferViews"][name];
      var bf = _resources["Buffer_${bv["buffer"]}"];
      bv["buffer"] = bf;
      bv["data"] = bf["data"];
      _resources[key] = bv;
      return bv;
    }
  }

  Material _getMaterial(Map doc, String name) {
    var key = "Material_${name}";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var material = new StandardMaterial();
      var technique = doc["materials"][name]["instanceTechnique"];
      material.technique = _getTechnique(doc, technique["technique"]);
      var values = technique["values"];
      var transparency = values["transparency"];
      if (transparency is num) {
        material.alpha = transparency;
      }
      var diffuse = values["diffuse"];
      if (diffuse is String) {
        material.diffuseTexture = _getTexture(doc, diffuse);
      } else if (diffuse is List) {
        material.diffuseColor = new Color.fromList(diffuse);
      }
      material.diffuseColor.alpha *= material.alpha;
      var ambient = values["ambient"];
      if (ambient is String) {
        material.ambientTexture = _getTexture(doc, ambient);
      } else if (ambient is List) {
        material.ambientColor = new Color.fromList(ambient);
      }
      var specular = values["specular"];
      if (specular is String) {
        material.specularTexture = _getTexture(doc, specular);
      } else if (specular is List) {
        material.specularColor = new Color.fromList(specular);
      }
      var shininess = values["shininess"];
      if (shininess != null) {
        material.shininess = shininess.toDouble();
      }
      _resources[key] = material;
      return material;
    }
  }

  Texture _getTexture(Map doc, String name) {
    var key = "Texture_$name";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var descripton = doc["textures"][name];
      descripton["path"] = _uri.resolve(doc["images"][descripton["source"]]["path"]).toString();
      descripton["sampler"] = _getSampler(doc, descripton["sampler"]);
      var texture = Texture.load(_ctx, descripton);
      _resources[key] = texture;
      return texture;
    }
  }

  Sampler _getSampler(Map doc, String name) {
    var key = "Sampler_$name";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var v = doc["samplers"][name];
      var sampler = new Sampler();
      sampler.magFilter = _ensureType(v["magFilter"]);
      sampler.minFilter = _ensureType(v["minFilter"]);
      sampler.wrapS = _ensureType(v["wrapS"]);
      sampler.wrapT = _ensureType(v["wrapT"]);
      _resources[key] = sampler;
      return sampler;
    }
  }

  Technique _getTechnique(Map doc, String name) {
    var key = "Technique_$name";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var technique = new Technique();
      technique.passes = {};
      doc["techniques"][name]["passes"].forEach((String pn, Map p) {
        var pass = new Pass();
        var states = p["states"];
        if (states.containsKey("blendEnable")) pass.blending = states["blendEnable"] == 1;
        if (states.containsKey("blendEquation")) pass.blendEquation = states["blendEquation"];
        if (states.containsKey("blendFunc")) {
          pass.dfactor = states["blendFunc"]["dfactor"];
          pass.sfactor = states["blendFunc"]["sfactor"];
        }
        if (states.containsKey("cullFaceEnable")) pass.cullFaceEnable = states["cullFaceEnable"] == 1;
        if (states.containsKey("depthMask")) pass.depthMask = states["depthMask"] == 1;
        if (states.containsKey("depthTestEnable")) pass.depthTest = states["depthTestEnable"] == 1;
        // TODO more..
        technique.passes[pn] = pass;
      });
      technique.pass = technique.passes[doc["techniques"][name]["pass"]];
      _resources[key] = technique;
      return technique;
    }
  }

  _loadBuffer(String name, Map doc) {
    var completer = new Completer();
    html.HttpRequest.request(_uri.resolve(doc["path"]).toString(), responseType: doc["type"]).then((response) {
      doc["name"] = name;
      doc["data"] = response.response;
      _resources["Buffer_${name}"] = doc;
      completer.complete(doc);
    });
    return completer.future;
  }

  Matrix4 _newMatrix4FromSQT(List s, List r, List t) {
    var m = new Matrix4.zero();
    m.setFromTranslationRotation(new Vector3.fromFloat32List(new Float32List.fromList(t)), new Quaternion.fromFloat32List(new Float32List.fromList(r)));
    m.scale(s[0].toDouble(), s[1].toDouble(), s[2].toDouble());
    return m;
  }

  Matrix4 _newMatrix4FromList(List l) {
    var tl = new Float32List(l.length);
    for (var i = 0; i < l.length; i++) {
      tl[i] = l[i].toDouble();
    }
    return new Matrix4.fromFloat32List(tl);
  }

  _newVec3FromList(List l) {
    return new Vector3(l[0].toDouble(), l[1].toDouble(), l[2].toDouble());
  }
}
