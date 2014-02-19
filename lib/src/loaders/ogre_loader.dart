part of orange;



class OgreLoader {
  gl.RenderingContext _ctx;
  Mesh _mesh;
  Uri _uri;
  Map<String, Material> _materials;
  
  Future<Mesh> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _mesh = new Mesh();
    var completer = new Completer<Mesh>();
    html.HttpRequest.getString(url).then((rsp){
      var json = JSON.decode(rsp);
      _parseMaterials(json["materials"]);
      _mesh = _parseMesh(json["mesh"]);
      if(json.containsKey("animations")) {
        var animator = new AnimationController(_mesh);
        animator.animations = {};
        json["animations"].forEach((a) {
          var animation = _parseAnimation(a);
          animator.animations[animation.name] = animation;
        });
      }
      completer.complete(_mesh);
    });
    return completer.future;
  }
  
  _parseMaterials(Map doc) {
    var textureManager = new TextureManager();
    _materials = {};
    doc.forEach((String n, Map m) {
      var material = new Material();
      material.name = m["name"];
      var specular = m["specular"];
      material.shininess = specular[3];
      material.specularColor = new Color.fromList([specular[0], specular[1], specular[2]]);
      material.emissiveColor = new Color.fromList(m["emissive"]);
      material.ambientColor = new Color.fromList(m["ambient"]);
      material.diffuseColor = new Color.fromList(m["diffuse"]);
      textureManager.load(_ctx,  {"path": _uri.resolve(m["texture"]).toString()}).then((t) => material.texture = t);
      _materials[material.name] = material;
    });
  }
  
  _parseMesh(Map doc) {
    var mesh = new Mesh();
    if(doc.containsKey("geometry")) {
      var geo = doc["geometry"];
      var geometry = new Geometry();
      geometry.vertexCount = geo["vertexcount"].toInt();
      // TODO should be merge into one buffer and upload once.
      geometry.buffers = {};
      geometry.buffers[Semantics.position] = _createBufferView(new Float32List.fromList(geo["positions"]), 3, gl.FLOAT);
      geometry.buffers[Semantics.normal] = _createBufferView(new Float32List.fromList(geo["normals"]), 3, gl.FLOAT);
      geometry.buffers[Semantics.texcoords] = _createBufferView(new Float32List.fromList(geo["texturecoords"]), 2, gl.FLOAT);
      if(doc.containsKey("jointindices") && doc.containsKey("jointweights")) {
        geometry.buffers[Semantics.joints] = _createBufferView(new Uint16List.fromList(doc["jointindices"]), 4, gl.UNSIGNED_SHORT);
        geometry.buffers[Semantics.weights] = _createBufferView(new Float32List.fromList(doc["jointweights"]), 4, gl.FLOAT);
      }
      mesh.geometry = geometry;
    }
    if(doc.containsKey("material")) {
      mesh.material = _materials[doc["material"]];
    }
    if(doc.containsKey("faces")) {
      var data = new Uint16List.fromList(doc["faces"]);
      mesh.faces = new BufferView(0, gl.UNSIGNED_SHORT, 0, 0, count: data.length, data: data, target: gl.ELEMENT_ARRAY_BUFFER);
    }
    if(doc.containsKey("skeleton")) {
      mesh.skeleton = _parseSkeleton(doc["skeleton"]);
    }
    if(doc.containsKey("submeshes")) {
      doc["submeshes"].forEach((submesh) => mesh.add(_parseMesh(submesh)));
    }
    return mesh;
  }
  
  Skeleton _parseSkeleton(Map doc) {
    var skeleton = new Skeleton();
    skeleton.joints = [];
    doc["joints"].forEach((j) {
      var joint = new Joint();
      joint.id = j["id"];
      if(j.containsKey("parent")) {
        joint.parentId = j["parent"];
      } else {
        joint.parentId = -1;
      }
      joint.name = j["name"];
      joint.position = new Vector3.fromList(j["position"]);
      joint.rotation = _parseRotation(j["rotation"]);
      skeleton.joints.add(joint);
    });
    skeleton.buildHierarchy();
    return skeleton;
  }
  
  Animation _parseAnimation(Map doc) {
    var animation = new Animation();
    animation.name = doc["name"];
    animation.length = doc["length"].toDouble();
    animation.tracks = [];
    doc["tracks"].forEach((t) {
      var track = new Track();
      track.jointId = t["joint"];
      track.keyframes = [];
      t["keyframes"].forEach((k) {
        var keyframe = new Keyframe();
        keyframe.time = k["time"].toDouble();
        keyframe.rotate = _parseRotation(k["rotate"]);
        keyframe.translate = new Vector3.fromList(k["translate"]);
        track.keyframes.add(keyframe);
      });
      animation.tracks.add(track);
    });
    animation.skeleton = _parseSkeleton(doc);
    return animation;
  }
  
  _parseRotation(Map rot) => new Quaternion.axisAngle(new Vector3.fromList(rot["axis"]), rot["angle"].toDouble());
  
  _createBufferView(TypedData data, int size, int type) {
    return new BufferView(size, type, 0, 0, count: 0, data: data);
  }
}


























