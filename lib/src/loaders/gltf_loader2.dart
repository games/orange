part of orange;





class GltfLoader2 {
  gl.RenderingContext _ctx;
  Mesh _root;
  Uri _uri;
  Map<String, dynamic> _resources;
  Map<String, Skeleton> _skeletons;
  Map<String, Joint> _joints;
  Map<String, List<String>> _childrenOfNode;
  Map<String, List<String>> _jointsOfSkeleton;
  Map<String, Map> _skinOfNode;
  Animation _animation;

  Future<Mesh> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _root = new Mesh();
    _resources = {};
    _skeletons = {};
    _joints = {};
    _childrenOfNode = {};
    _jointsOfSkeleton = {};
    _skinOfNode = {};
    var completer = new Completer<Mesh>();
    html.HttpRequest.getString(url).then((rsp) {
      var json = JSON.decode(rsp);
      var loadBufferFutures = [];
      json["buffers"].forEach((k, v) => loadBufferFutures.add(_loadBuffer(k, v)));
      Future.wait(loadBufferFutures).then((List buffers) {
        _parseNodes(json);
        _parseSkins(json);
        _parseAnimations(json);
        _parseScene(json);
        completer.complete(_root);
      });
    }).catchError((Error e) => print([e, e.stackTrace]));
    return completer.future;
  }

  void _parseAnimations(Map doc) {
    if (doc.containsKey("animations")) {
      var animation = new Animation();
      animation.name = "default";
      animation.tracks = [];
      animation.length = 0.0;
      doc["animations"].forEach((String k, Map ani) {
        var track = new Track();
        var channels = ani["channels"] as List;
        track.jointName = channels.first["target"]["id"];
        var joint = _resources["Node_${track.jointName}"] as Joint;
        track.jointId = joint.jointId;
        track.keyframes = [];

        var parameters = {};
        ani["parameters"].forEach((k, p) => parameters[k] = _getAttribute(doc, p, k));
        // track
        var count = ani["count"];
        for (var i = 0; i < count; i++) {
          var keyframe = new Keyframe();
          channels.forEach((Map ch) {
            var path = ch["target"]["path"];
            var buffer = parameters[path] as VertexBuffer;
            var list = buffer.data as Float32List;
            var idx = i * buffer.size;
            if (path == "rotation") {
              keyframe.rotate = new Quaternion.axisAngle(new Vector3(list[idx], list[idx + 1], list[idx + 2]), list[idx + 3]);
            } else if (path == "scale") {
              keyframe.scaling = new Vector3(list[idx], list[idx + 1], list[idx + 2]);
            } else if (path == "translation") {
              keyframe.translate = new Vector3(list[idx], list[idx + 1], list[idx + 2]);
            }
          });
          keyframe.time = parameters["TIME"].data[i];
          track.keyframes.add(keyframe);
        }
        animation.tracks.add(track);
      });
      if (animation.tracks.length > 0) {
        animation.length = animation.tracks.first.keyframes.last.time;
        _animation = animation;
      }
    }
  }

  void _parseSkins(Map doc) {
    if (doc.containsKey("skins")) {
      _skeletons = {};
      doc["skins"].forEach((String k, Map v) {
        var skeleton = new Skeleton();
        skeleton.name = k;
        skeleton.joints = [];
        for (var i = 0; i < v["joints"].length; i++) {
          var joint = _joints[v["joints"][i]];
          joint.jointId = i;
          skeleton.joints.add(joint);
        }
        skeleton.joints.forEach((joint) {
          if (joint.parent == null) joint.parentId = -1; else if (joint.parent is Joint) joint.parentId = joint.parent.jointId;
        });
        var buffer = _getBufferData(doc, v["inverseBindMatrices"]) as Float32List;
        for (var i = 0; i < skeleton.joints.length; i++) {
          skeleton.joints[i]._inverseBindMatrix = new Matrix4.fromBuffer(buffer.buffer, buffer.offsetInBytes + i * 4 * 16);
        }
        skeleton._bindShapeMatrix = _newMatrix4FromList(v["bindShapeMatrix"]);
        skeleton.buildHierarchy();
        _skeletons[k] = skeleton;
      });
    }
  }

  void _parseScene(Map doc) {
    var scene = doc["scenes"][doc["scene"]];
    var nodes = [];
    scene["nodes"].forEach((String id) {
      var key = "Node_${id}";
      if (_resources.containsKey(key)) {
        var node = _resources[key] as Node;
        // TODO fixme
        if (!(node is Joint)) nodes.add(node);
      }
    });
    if (nodes.length == 1) {
      _root = nodes.first;
    } else {
      nodes.forEach((node) => _root.add(node));
    }
    nodes.forEach((n) => _setupSkeleton(n));
  }

  // TODO fixme
  void _setupSkeleton(Node node) {
    if (!(node is Mesh)) return;
    var mesh = node as Mesh;
    var skin = _skinOfNode[node.id];
    if (skin != null) {
      var skeleton = _skeletons[skin["skin"]];
      mesh.skeleton = skeleton;
      if (_animation != null) {
        mesh.animator = new AnimationController(node);
        mesh.animator.bindPose = false;
        mesh.animator.animations = {};
        mesh.animator.animations["default"] = _animation;
        mesh.animator.switchAnimation("default");
        _animation.skeleton = skeleton;
      }
      mesh.children.forEach((c) => _setupSkeleton(c));
    }
  }

  void _parseNodes(Map doc) {
    var nodes = [];
    doc["nodes"].forEach((String id, Map v) {
      var node;
      if (v.containsKey("jointId")) {
        node = new Joint();
        node.id = id;
        _joints[v["jointId"]] = node;
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
        v["instanceSkin"]["sources"].forEach((src) {
          node.add(_getMesh(doc, src));
        });
        _skinOfNode[node.id] = v["instanceSkin"];
      } else {
        node = new Mesh(name: id);
      }
      if (v.containsKey("matrix")) {
        node.applyMatrix(_newMatrix4FromList(v["matrix"]));
      } else if (v.containsKey("translation")) {
        node.applyMatrix(_newMatrix4FromSQT(v["scale"], v["rotation"], v["translation"]));
      }
      if (v.containsKey("children")) {
        _childrenOfNode[node.id] = v["children"];
      }
      _resources["Node_${node.id}"] = node;
      nodes.add(node);
    });
    // build node hierarchy
    nodes.forEach((Node node) {
      _childrenOfNode[node.id].forEach((id) {
        var child = _resources["Node_${id}"];
        if (child.parent != null) {
          node.add(child.clone());
        } else {
          node.add(child);
        }
      });
    });
  }

  Node _getMesh(Map doc, String id) {
    var key = "Mesh_${id}";
    if (_resources.containsKey(key)) {
      return _resources[key].clone();
    } else {
      var m = doc["meshes"][id];
      var node = new Mesh(name: id);
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
          } else if (at == "JOINT") {
            child._geometry.buffers[Semantics.joints] = _getAttribute(doc, ar, Semantics.joints);
          } else if (at == "WEIGHT") {
            child._geometry.buffers[Semantics.weights] = _getAttribute(doc, ar, Semantics.weights);
          }
        });
        child.material = _getMaterial(doc, p["material"]);
        child.primitive = p.containsKey("primitive") ? p["primitive"] : gl.TRIANGLES;
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
      var type = attr["type"],
          size = _sizeOfType(type),
          count = attr["count"];
      if (semantics == Semantics.position) {
        // TODO bounding box ?
      }
      if (type != gl.UNSIGNED_SHORT) type = gl.FLOAT;
      var vertexBuffer = new VertexBuffer(size, type, 0, 0, count: count, data: _getBufferData(doc, attr), target: view["target"]);
      _resources[key] = vertexBuffer;
      return vertexBuffer;
    }
  }

  TypedData _getBufferData(Map root, Map desc) {
    var view = _getBufferView(root, desc["bufferView"]);
    var offset = desc["byteOffset"],
        count = desc["count"];
    if (desc["type"] == gl.UNSIGNED_SHORT) {
      return new Uint16List.view(view["data"], view["byteOffset"] + offset, count);
    } else {
      return new Float32List.view(view["data"], view["byteOffset"] + offset, count * _sizeOfType(desc["type"]));
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
        material.alpha = transparency.toDouble();
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
    var type = "arraybuffer";
    if (doc.containsKey("type")) type = doc["type"];
    html.HttpRequest.request(_uri.resolve(doc["path"]).toString(), responseType: type).then((response) {
      doc["name"] = name;
      doc["data"] = response.response;
      _resources["Buffer_${name}"] = doc;
      completer.complete(doc);
    });
    return completer.future;
  }

  int _sizeOfType(int type) {
    var size = 0;
    switch (type) {
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
        size = 8;
        break;
      case gl.FLOAT_MAT3:
        size = 12;
        break;
      case gl.FLOAT_MAT4:
        size = 16;
        break;
      case gl.UNSIGNED_SHORT:
        size = 1;
        break;
      default:
        throw new ArgumentError("Not support type '${type}'");
    }
    return size;
  }

}
