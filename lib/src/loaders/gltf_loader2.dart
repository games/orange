part of orange;





class GltfLoader2 {
  gl.RenderingContext _ctx;
  Node _root;
  Uri _uri;
  Map<String, dynamic> _resources;
  Map<String, Joint> _joints;
  Map<String, List<String>> _childrenOfNode;
  Map<String, List<String>> _jointsOfSkeleton;
  Vector3 _boundingBoxMin = new Vector3.all(double.MAX_FINITE);
  Vector3 _boundingBoxMax = new Vector3.all(-double.MAX_FINITE);

  Map<String, VertexBuffer> _bufferViews;

  Future<List<Node>> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _root = new Node();
    _resources = {};
    _joints = {};
    _childrenOfNode = {};
    _jointsOfSkeleton = {};
    var completer = new Completer<List<Node>>();
    html.HttpRequest.getString(url).then((rsp) {
      var json = JSON.decode(rsp);
      var loadBufferFutures = [];
      json["buffers"].forEach((k, v) => loadBufferFutures.add(_loadBuffer(k, v)));
      Future.wait(loadBufferFutures).then((List buffers) {
        _makeNodes(json);
        var nodes = _makeScene(json);
        completer.complete(nodes);
      });
    }).catchError((Error e) => print([e, e.stackTrace]));
    return completer.future;
  }

  List<Node> _makeScene(Map doc) {
    var s = doc["scenes"][doc["scene"]];
    var nodes = [];
    s["nodes"].forEach((String name) {
      var key = "Node_${name}";
      if (_resources.containsKey(key)) {
        var node = _resources[key] as Node;
        nodes.add(node);
      }
    });
    nodes.forEach((node) => _buildNodeHierarchy(node));
    var root = nodes.firstWhere((e) => e is Mesh) as Mesh;
    root._boundingInfo = new BoundingInfo(_boundingBoxMin, _boundingBoxMax);
    return nodes;
  }

  _buildNodeHierarchy(Node node) {
    var childNames = _childrenOfNode[node.name];
    childNames.forEach((name) {
      var child = _resources["Node_${name}"];
      node.add(child);
      _buildNodeHierarchy(child);
    });
  }

  void _makeNodes(Map doc) {
    var nodes = doc["nodes"];
    nodes.forEach((String k, Map v) {
      var node;
      if (v.containsKey("jointId")) {
        return;
      } else if (v.containsKey("light")) {
        return;
      } else if (v.containsKey("camera")) {
        return;
      } else if (v.containsKey("meshes")) {
        node = new Mesh(name: v["name"]);
        v["meshes"].forEach((m) {
          node.add(_getMesh(doc, m));
        });
      } else if (v.containsKey("instanceSkin")) {
        node = new Mesh(name: v["name"]);
        // TODO
      } else {
        node = new Mesh(name: v["name"]);
      }
      if (v.containsKey("matrix")) {
        node.applyMatrix(_mat4FromList(v["matrix"]));
      } else if (v.containsKey("translation")) {
        node.applyMatrix(_newMatrix4FromSQT(v["scale"], v["rotation"], v["translation"]));
      }
      if (v.containsKey("children")) {
        _childrenOfNode[node.name] = v["children"];
      }
      _resources["Node_$k"] = node;
    });
  }

  Node _getMesh(Map doc, String name) {
    var key = "Mesh_${name}";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var m = doc["meshes"][name];
      var node = new Node(name: m["name"]);
      m["primitives"].forEach((p) {
        var child = new Mesh();
        child._geometry = new Geometry();
        child.indices = _getAttributes(doc, p["indices"]);
        p["attributes"].forEach((String at, String ar) {
          if (at == "NORMAL") {
            child._geometry.normals = _getAttributes(doc, ar);
          } else if (at == "POSITION") {
            child._geometry.positions = _getAttributes(doc, ar);
          } else if (at == "TEXCOORD_0") {
            child._geometry.texCoords = _getAttributes(doc, ar);
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

  VertexBuffer _getAttributes(Map doc, String name) {
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
          size = 2;
          type = gl.UNSIGNED_SHORT;
          break;
      }
      if (attr["type"] == gl.FLOAT_VEC3) {
        Vector3.min(_newVec3FromList(attr["min"]), _boundingBoxMin, _boundingBoxMin);
        Vector3.max(_newVec3FromList(attr["max"]), _boundingBoxMax, _boundingBoxMax);
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
      var diffuse = values["diffuse"];
      if (diffuse is String) {
        material.diffuseTexture = _getTexture(doc, diffuse);
      } else if (diffuse is List) {
        material.diffuseColor = new Color.fromList(diffuse);
      }
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
      material.shininess = values["shininess"];
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
    var technique = new Technique();
    technique.passes = {};
    doc["techniques"][name]["passes"].forEach((String pn, Map p) {
      var pass = new Pass();
      if (p.containsKey("blendEnable")) pass.blending = p["blendEnable"] == 1;
      if (p.containsKey("blendEquation")) pass.blendEquation = p["blendEquation"];
      if (p.containsKey("blendFunc")) {
        pass.dfactor = p["blendFunc"]["dfactor"];
        pass.sfactor = p["blendFunc"]["sfactor"];
      }
      if (p.containsKey("cullFaceEnable")) pass.cullFaceEnable = p["cullFaceEnable"] == 1;
      if (p.containsKey("depthMask")) pass.depthMask = p["depthMask"] == 1;
      if (p.containsKey("depthTestEnable")) pass.depthTest = p["depthTestEnable"] == 1;
      // TODO more..
      technique.passes[pn] = pass;
    });
    technique.pass = technique.passes[doc["techniques"][name]["pass"]];
    return technique;
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

  _newVec3FromList(List l) {
    return new Vector3(l[0].toDouble(), l[1].toDouble(), l[2].toDouble());
  }
}
