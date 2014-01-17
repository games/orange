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
      json["animations"].forEach((a) {
        var animator = new AnimationController();
        animator.name = a["name"];
        animator.skeleton = Parser.parseSkeleton(a);
        animator.animation = Parser.parseClip(a["animation"]);
      });
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
      material.emissiveColor = new Float32List.fromList(m["emissive"]);
      material.specularColor = new Float32List.fromList(m["specular"]);
      material.ambientColor = new Float32List.fromList(m["ambient"]);
      material.diffuseColor = new Float32List.fromList(m["diffuse"]);
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
      geometry.buffers[Semantics.texture] = _createBufferView(new Float32List.fromList(geo["texturecoords"]), 2, gl.FLOAT);
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
      var buffer = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer);
      _ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, data, gl.STATIC_DRAW);
      mesh.faces = new BufferView(0, gl.UNSIGNED_SHORT, 0, 0, data.length, buffer);
    }
    if(doc.containsKey("skeleton")) {
      mesh.skeleton = Parser.parseSkeleton(doc["skeleton"]);
    }
    
    if(doc.containsKey("submeshes")) {
      doc["submeshes"].forEach((submesh) => mesh.add(_parseMesh(submesh)));
    }
    return mesh;
  }
  
  _createBufferView(TypedData data, int size, int type) {
    var buffer = _ctx.createBuffer();
    _ctx.bindBuffer(gl.ARRAY_BUFFER, buffer);
    _ctx.bufferDataTyped(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
    return new BufferView(size, type, 0, 0, 0, buffer);
  }
}


























