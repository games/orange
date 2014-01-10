part of orange;



class GltfLoader {
  
  Node _root;
  Uri _uri;
  Map<String, Object> _resources;
  
  Future<Node> load(gl.RenderingContext ctx, String url) {
    _uri = Uri.parse(url);
    _root = new Node();
    var completer = new Completer();
    html.HttpRequest.getString(url)
      .then((rsp){
          if(_parse(JSON.decode(rsp))){
            completer.complete(_root);
          }else{
            completer.completeError("parse failure");
          }
      })
      .catchError((Error e) => print([e, e.stackTrace]));
    return completer.future;
  }
  
  _parse(json) {
    var categoriesDepsOrder = ["buffers", "bufferViews", "images",  "videos", "samplers", "textures", 
                               "shaders", "programs", "techniques", "materials", "accessors",
                               "meshes", "cameras", "lights", "skins", "nodes", "scenes", "animations"];
    
    var loadBufferFutures = [];
    json["buffers"].forEach((k, v) => loadBufferFutures.add(_loadBuffer(k, v)));
    Future.wait(loadBufferFutures).then((List buffers) {
      handleBufferViews(json);
      
    });
   
  }
  
  _loadBuffer(String name, Map doc) {
    var completer = new Completer();
    html.HttpRequest.request(_uri.resolve(doc["path"]).toString(), responseType: "arraybuffer").then((response) {
      doc["name"] = name;
      doc["data"] = response.response;
      _storageResource("buffer", name, doc);
      completer.complete(doc);
    });
    return completer.future;
  }
  
  handleBufferViews(Map doc) {
    doc.forEach((k, v){
      _storageResource("bufferView", k, v);
    });
  }
  
  handleImages(Map description) {
    description.forEach((k, v){
      _storageResource("image", k, v);
    });
  }
  
  handleTextures(Map description) {
    description.forEach((k, v){
      v["path"] = _uri.resolve(_getResource("image", v["source"])["path"]).toString();
      _storageResource("texture", k, v);
    });
  }
  
  handleMaterials(Map description) {
    description.forEach((k, v){
      v["diffuse"] = _getResource("texture", v["instanceTechnique"]["values"]["diffuse"]);
      _storageResource("material", k, v);
    });
  }
  
  handleAccessors(description) {
    description.forEach((k, v){
      _storageResource("accessor", k, v);
    });
  }
  
  handleMeshes(Map description) {
    description.forEach((k, v){
      var mesh = new Mesh();
      mesh.name = v["name"];
      var primitives = v["primitives"];

      //TODO : parse sub meshes  
      mesh.subMeshes = new List.generate(primitives.length, (i){
        var p = primitives[i];
        var indicesAttrib = _getResource("accessor", p["indices"]);
        var primitiveType = p["primitive"];
        var attributes = p["attributes"];
        
        var primitive = new Mesh();
        primitive.material = p["material"];
        primitive.indicesAttrib = new MeshAttribute(2, gl.UNSIGNED_SHORT, 0,
            indicesAttrib["byteOffset"] + _getResource("bufferView", indicesAttrib["bufferView"])["byteOffset"], 
            indicesAttrib["count"]);
        
        primitive.attributes = {};
        attributes.forEach((ak, av) {
          var accessor = _getResource("accessor", av);
          var bufferView = _getResource("bufferView", accessor["bufferView"]);
          if(ak == "NORMAL") {
            primitive.attributes[Semantics.normal] = new MeshAttribute(
                accessor["byteStride"] ~/ 4, 
                gl.FLOAT, 0, 0, 0);
          }
        });
        
        
        return primitive;
      }, growable: false);
      _root.meshes.add(mesh);
    });
  }
  
  handleSkins(description) {
    // TODO
  }
  
  handleNodes(Map description) {
    // TODO
  }
  
  
  _storageResource(String kind, String name, resource) => _resources["${kind}_$name"] = resource;
  _getResource(String kind, String name) => _resources["${kind}_$name"];
}




























