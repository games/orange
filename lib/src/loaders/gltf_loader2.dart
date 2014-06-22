part of orange;





class GltfLoader2 {
  gl.RenderingContext _ctx;
  Mesh _root;
  Uri _uri;
  Map<String, dynamic> _resources;
  Map<String, Joint> _joints;
  Map<String, List<String>> _childrenOfNode;
  Map<String, List<String>> _jointsOfSkeleton;

  Map<String, VertexBuffer> _bufferViews;

  Future<Mesh> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _root = new Mesh();
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
        _handleNodes(json);
        completer.complete(_root);
      });
    }).catchError((Error e) => print([e, e.stackTrace]));
    return completer.future;
  }

  void _handleNodes(Map doc) {
    var nodes = doc["nodes"];
    nodes.forEach((String k, Map v) {
      if (v.containsKey("meshes")) {
        var node = new Mesh(name: v["name"]);
        if (v.containsKey("matrix")) {
          node.applyMatrix(_mat4FromList(v["matrix"]));
        } else {
          node.applyMatrix(_newMatrix4FromSQT(v["scale"], v["rotation"], v["translation"]));
        }
        v["meshes"].forEach((m) {
          node.children.add(_handleMesh(doc, m));
        });
        _root.children.add(node);
      }
    });
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
          offset = attr["byteOffset"];
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
      var vertexBuffer = new VertexBuffer(size, type, stride, offset, count: attr["count"], data: view["data"], target: view["target"]);
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
      var t = bv["target"];
      if (t == gl.ELEMENT_ARRAY_BUFFER) {
        bv["data"] = new Uint16List.view(bf["data"], bv["byteOffset"], bv["byteLength"] ~/ 2);
      } else {
        bv["data"] = new Float32List.view(bf["data"], bv["byteOffset"], bv["byteLength"] ~/ 4);
      }
      _resources[key] = bv;
      return bv;
    }
  }

  Mesh _handleMesh(Map doc, String name) {
    var m = doc["meshes"][name];
    var mesh = new Mesh(name: m["name"]);
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
      mesh.children.add(child);
    });

    return mesh;
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
    var key = "Technique_$name";
    if (_resources.containsKey(key)) {
      return _resources[key];
    } else {
      var technique = new Technique();
      technique.passes = {};
      doc["techniques"][name]["passes"].forEach((String pn, Map p) {
        var pass = new Pass();
        if (p.containsKey("blendEnable")) pass.blending = p["blendEnable"] == 1;
        if (p.containsKey("cullFaceEnable")) pass.cullFaceEnable = p["cullFaceEnable"] == 1;
        if (p.containsKey("depthMask")) pass.depthMask = p["depthMask"] == 1;
        if (p.containsKey("depthTestEnable")) pass.depthTest = p["depthTestEnable"] == 1;
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
}



