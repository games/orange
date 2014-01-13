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
      // TODO needs to optimize.
      material.parameters = {
        "emissive": m["emissive"],
        "specular": m["specular"],
        "ambient": m["ambient"],
        "diffuse": m["diffuse"]
      };
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
      
      var data = new Float32List.fromList(geo["positions"]);
      var buffer = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ARRAY_BUFFER, buffer);
      _ctx.bufferDataTyped(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
      geometry.buffers[Semantics.position] = new BufferView(3, gl.FLOAT, 0, 0, 0, buffer);
      
      data = new Float32List.fromList(geo["normals"]);
      buffer = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ARRAY_BUFFER, buffer);
      _ctx.bufferDataTyped(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
      geometry.buffers[Semantics.normal] = new BufferView(3, gl.FLOAT, 0, 0, 0, buffer);
      
      data = new Float32List.fromList(geo["texturecoords"]);
      buffer = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ARRAY_BUFFER, buffer);
      _ctx.bufferDataTyped(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
      geometry.buffers[Semantics.texture] = new BufferView(2, gl.FLOAT, 0, 0, 0, buffer);
      
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
      var skeleton = new Skeleton();
      skeleton.joints = [];
      doc["skeleton"]["joints"].forEach((j) {
        var joint = new Joint();
        joint.id = j["id"];
        if(j.containsKey("parent")) {
          joint.parentId = j["parent"];
        } else {
          joint.parentId = -1;
        }
        joint.name = j["name"];
        joint.position = new Vector3.fromList(j["position"]);
        var rot = j["rotation"];
        joint.rotation = new Quaternion.axisAngle(new Vector3.fromList(rot["axis"]), rot["angle"]);
        skeleton.joints.add(joint);
      });
    }
    if(doc.containsKey("submeshes")) {
      doc["submeshes"].forEach((submesh) => mesh.add(_parseMesh(submesh)));
    }
    return mesh;
  }
}


























