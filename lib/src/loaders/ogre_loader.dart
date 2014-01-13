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
      var data = new Float32List.fromList(geo["positions"]);
      geometry.positions = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ARRAY_BUFFER, geometry.positions);
      _ctx.bufferDataTyped(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
      
      data = new Float32List.fromList(geo["normals"]);
      geometry.normals = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ARRAY_BUFFER, geometry.normals);
      _ctx.bufferDataTyped(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
      
      data = new Float32List.fromList(geo["texturecoords"]);
      geometry.textureCoords = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ARRAY_BUFFER, geometry.textureCoords);
      _ctx.bufferDataTyped(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
      
      mesh.geometry = geometry;
    }
    if(doc.containsKey("material")) {
      mesh.material = _materials[doc["material"]];
    }
    if(doc.containsKey("faces")) {
      var data = new Uint16List.fromList(doc["faces"]);
      mesh.faces = _ctx.createBuffer();
      _ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.faces);
      _ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, data, gl.STATIC_DRAW);
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
        joint.pos = new Vector3.fromList(j["position"]);
        var rot = j["rotation"];
        joint.rot = new Quaternion.axisAngle(new Vector3.fromList(rot["axis"]), rot["angle"]);
        skeleton.joints.add(joint);
      });
    }
    if(doc.containsKey("submeshes")) {
      doc["submeshes"].forEach((submesh) => mesh.children.add(_parseMesh(submesh)));
    }
    return mesh;
  }
}


























