part of orange;



class GltfLoader {
  gl.RenderingContext _ctx;
  Node _root;
  Uri _uri;
  Map<String, dynamic> _resources;
  Map<String, Joint> _joints;
  Map<String, List<String>> _nodeHierarchy;
  
  Future<Node> load(gl.RenderingContext ctx, String url) {
    _ctx = ctx;
    _uri = Uri.parse(url);
    _root = new Node();
    _resources = {};
    _joints = {};
    _nodeHierarchy = {};
    var completer = new Completer();
    html.HttpRequest.getString(url).then((rsp){
        var json = JSON.decode(rsp);
        var loadBufferFutures = [];
        json["buffers"].forEach((k, v) => loadBufferFutures.add(_loadBuffer(k, v)));
        Future.wait(loadBufferFutures).then((List buffers) {
          
          
          handleBufferViews(json["bufferViews"]);
          handleImages(json["images"]);
          handleTextures(json["textures"]);
          handleMaterials(json["materials"]);
          handleAccessors(json["accessors"]);
          handleMeshes(json["meshes"]);
          handleSkins(json["skins"]);
          handleNodes(json["nodes"]);
          handleScenes(json["scenes"]);

          completer.complete(_root);
        });
      })
      .catchError((Error e) => print([e, e.stackTrace]));
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
      var target = v["target"];
      if(target == gl.ARRAY_BUFFER) {
        var vert = new Float32List.view(buffer, v["byteOffset"], v["byteLength"] ~/ 4);
        _root.vertexBuffer = _ctx.createBuffer();
        _ctx.bindBuffer(gl.ARRAY_BUFFER, _root.vertexBuffer);
        _ctx.bufferDataTyped(gl.ARRAY_BUFFER, vert, gl.STATIC_DRAW);
      } else if (target == gl.ELEMENT_ARRAY_BUFFER) {
        var idx = new Uint16List.view(buffer, v["byteOffset"], v["byteLength"] ~/ 2);
        _root.indexBuffer = _ctx.createBuffer();
        _ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _root.indexBuffer);
        _ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, idx, gl.STATIC_DRAW);        
      }
      _resources[k] = v; 
    });
  }
  
  handleImages(Map doc) {
    doc.forEach((k, v) => _resources[k] = v);
  }
  
  handleTextures(Map description) {
    description.forEach((k, v){
      v["path"] = _uri.resolve(_resources[v["source"]]["path"]).toString();
      _resources[k] = v;
    });
  }
  
  handleMaterials(Map description) {
    description.forEach((k, v){
      v["diffuse"] = _resources[v["instanceTechnique"]["values"]["diffuse"]];
      _resources[k] = v;
    });
  }
  
  handleAccessors(description) {
    description.forEach((k, v){
      _resources[k] = v;
    });
  }
  
  handleMeshes(Map description) {
    description.forEach((k, v){
      var mesh = new Mesh();
      mesh.name = v["name"];
      var primitives = v["primitives"];
      mesh.subMeshes = new List.generate(primitives.length, (i){
        var p = primitives[i];
        var indicesAttrib = _resources[p["indices"]];
        var primitiveType = p["primitive"];
        var attributes = p["attributes"];
        
        var submesh = new Mesh();
        submesh.material = p["material"];
        submesh.indicesAttrib = new MeshAttribute(2, gl.UNSIGNED_SHORT, 0,
            indicesAttrib["byteOffset"] + _resources[indicesAttrib["bufferView"]]["byteOffset"], 
            indicesAttrib["count"]);
        
        submesh.attributes = {};
        attributes.forEach((ak, av) {
          var accessor = _resources[av];
          var bufferView = _resources[accessor["bufferView"]];
          var byteOffset = accessor["byteOffset"] + bufferView["byteOffset"];
          switch(ak) {
            case "NORMAL": 
              submesh.attributes[Semantics.normal] = new MeshAttribute(3, gl.FLOAT, 0, byteOffset);
              break;
            case "POSITION":
              submesh.attributes[Semantics.position] = new MeshAttribute(3, gl.FLOAT, 0, byteOffset);
              break;
            case "TEXCOORD_0":
              submesh.attributes[Semantics.texture] = new MeshAttribute(2, gl.FLOAT, 0, byteOffset);
              break;
            case "WEIGHT":
              submesh.attributes[Semantics.weights] = new MeshAttribute(3, gl.FLOAT, 0, byteOffset);
              break;
            case "JOINT":
              submesh.attributes[Semantics.bones] = new MeshAttribute(3, gl.FLOAT, 0, byteOffset);
              break;
          }
        });
        return submesh;
      }, growable: false);
      _resources[k] = mesh;
    });
  }
  
  handleSkins(Map description) {
    description.forEach((k, v) {
      List joints = v["joints"];
      var skeleton = new Skeleton();
      skeleton.jointMatrices = new Float32List(16 * joints.length);
      skeleton.joints = [];
      joints.forEach((j) {
        var joint = new Joint();
        joint.name = j;
        skeleton.joints.add(joint);
      });
      v["skeleton"] = skeleton;
      _resources[k] = v;
    });
  }
  
  handleNodes(Map description) {
    description.forEach((String k, Map v){
      var matrix;
      if(v.containsKey("matrix")) {
        matrix = new Matrix4.fromList(v["matrix"]);
      } else {
        matrix = _newMatrix4FromSQT(v["scale"], v["rotation"], v["translation"]);
      }
      var node;
      if(v.containsKey("jointId")) {
        node = new Joint();
        node.name = v["jointId"];
        _joints[node.name] = node;
      }else if(v.containsKey("light")) {
        return;
      } else if(v.containsKey("camera")) {
        return;
      } else {
        node = new Node();
        node.name = v["name"];
        if(v.containsKey("meshes")) {
          var meshes = v["meshes"];
          node.meshes = new List.generate(meshes.length, (i){
            return _resources[meshes[i]];
          }, growable: false);
        } else if(v.containsKey("mesh")) {
          node.meshes = [_resources[v["mesh"]]];
        } else if (v.containsKey("instanceSkin")) {
          var instanceSkin = v["instanceSkin"];
          node.skeleton = _resources[instanceSkin["skin"]];
          var source = instanceSkin["sources"];
          node.meshes = new List.generate(source.length, (i){
            return _resources[source[i]];
          }, growable: false);
        } else {
          node.meshes = new List(0);
        }
      }
      _nodeHierarchy[node.name] = v["children"];
      node.applyMatrix(matrix);
      _resources[k] = node;
    });
  }
  
  handleScenes(Map description) {
    var json = description.values.first;
    json["nodes"].forEach((name){
      var node = _resources[name];
      if(node != null) {
        if (node is Camera) {
          
        } else if(node is Node) {
          _root.add(node);
        }
      }
    });
    _root.children.forEach((node) => _buildNodeHierarchy(node));
    _root.updateMatrix();
    _buildSkins(_root);
  }
  
  _buildSkins(Node node) {
    if(node.skeleton != null) {
      
    }
  }
  
  _buildNodeHierarchy(Node node) {
    if(node.children == null)
      node.children = new List();
    var childNames = _nodeHierarchy[node.name];
    childNames.forEach((name){
      var child = _resources[name];
      node.add(child);
      _buildNodeHierarchy(child);
    });
  }
  
}



Matrix4 _newMatrix4FromSQT(List s, List r, List t) {
  var m = new Matrix4.zero();
  m.fromRotationTranslation(new Quaternion.fromList(r), new Vector3.fromList(t));
  m.scale(s[0].toDouble(), s[1].toDouble(), s[2].toDouble());
  return m;
}


























