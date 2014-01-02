part of orange;


class Loader {
  String _path;
  Uri _uri;
  Scene _scene;
  Resources _resources = new Resources();

  Loader(this._path) {
    _uri = Uri.parse(_path);
  }
  
  Future<Scene> start() {
    var completer = new Completer<Scene>();
    html.HttpRequest.getString(_path)
      .then((rsp){
          if(_parse(JSON.decode(rsp))){
            completer.complete(_scene);
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
    InstanceMirror mirror = reflect(this);
    return categoriesDepsOrder.every((category){
      var description = json[category];
      if(description != null)
        return mirror.invoke(new Symbol("handle${StringHelper.capitalize(category)}"), [description]).reflectee;
      return true;
    });
  }
  
  handleBuffers(Map description) {
    description.forEach((k, v){
      var buffer = new Buffer();
      buffer.path = _uri.resolve(v["path"]).toString();
      buffer.byteLength = v["byteLength"];
      buffer.type = v["type"];
      _resources[k] = buffer;
    });
    return true;
  }
  
  handleBufferViews(Map description) {
    description.forEach((k, v){
      var bufferView = new BufferView();
      bufferView.bufferRefs = _resources[v["buffer"]];
      bufferView.byteLength = v["byteLength"];
      bufferView.byteOffset = v["byteOffset"];
      bufferView.target = v["target"];
      _resources[k] = bufferView;
    });
    return true;
  }
  
  handleImages(Map description) {
    description.forEach((k, v){
      var image = new Image();
      image.name = v["name"];
      image.path = _uri.resolve(v["path"]).toString();
      image.generateMipmap = v["generateMipmap"];
      _resources[k] = image;
    });
    return true;
  }
  
  handleVideos(description) {
    return true;
  }
  
  handleSamplers(Map description) {
    description.forEach((k, v) {
      var sampler = new Sampler();
      sampler.magFilter = v["magFilter"];
      sampler.minFilter = v["minFilter"];
      sampler.wrapS = v["wrapS"];
      sampler.wrapT = v["wrapT"];
      _resources[k] = sampler;
    });
    return true;
  }
  
  handleTextures(Map description) {
    description.forEach((k, v){
      var texture = new Texture();
      texture.sampler = _resources[v["sampler"]];
      texture.path = _uri.resolve(_resources[v["source"]].path).toString();
      texture.target = v["target"];
      texture.format = v["format"];
      texture.internalFormat = v["internalFormat"];
      _resources[k] = texture;
    });
    return true;
  }
  
  handleShaders(Map description) {
    description.forEach((k, v){
      var shader = new Shader();
      shader.path = _uri.resolve(v["path"]).toString();
      _resources[k] = shader;
    });
    return true;
  }
  
  handlePrograms(Map description) {
    description.forEach((k, v){
      var program = new Program();
      program.attributes = v["attributes"];
      program.fragmentShader = _resources[v["fragmentShader"]];
      program.vertexShader = _resources[v["vertexShader"]];
      _resources[k] = program;
    });
    return true;
  }
  
  handleTechniques(Map description) {
    description.forEach((k, v){
      var technique = new Technique();
      technique.parameters = v["parameters"];
      technique.pass = v["pass"];
      technique.passes = new Map();
      v["passes"].forEach((k, v){
        var pass = new Pass();
        pass.name = k;
        pass.details = v["details"];
        pass.program = _resources[v["instanceProgram"]["program"]];
        pass.instanceProgram = v["instanceProgram"];
        pass.states = v["states"];
        technique.passes[k] = pass;
      });
      _resources[k] = technique;
    });
    return true;
  }
  
  handleMaterials(Map description) {
    description.forEach((k, v){
      var material = new Material();
      material.name = v["name"];
      material.technique = _resources[v["instanceTechnique"]["technique"]];
      material.instanceTechnique = v["instanceTechnique"];
      _resources[k] = material;
    });
    return true;  
  }
  
  handleAccessors(description) {
    description.forEach((k, v){
      var attr = new MeshAttribute();
      attr.bufferView = _resources[v["bufferView"]];
      attr.byteOffset = v["byteOffset"];
      attr.byteStride = v["byteStride"];
      attr.count = v["count"];
      attr.type = v["type"];
      attr.max = v["max"];
      attr.min = v["min"];
      attr.normalized = v["normalized"];
      _resources[k] = attr;
    });
    return true;
  }
  
  handleMeshes(Map description) {
    description.forEach((k, v){
      var mesh = new Mesh();
      mesh.name = v["name"];
      var primitives = v["primitives"];
      mesh.primitives = new List.generate(primitives.length, (i){
        var p = primitives[i];
        var primitive = new Primitive();
        primitive.indices = _resources[p["indices"]];
        primitive.primitive = p["primitive"];
        primitive.material = _resources[p["material"]];
        primitive.attributes = new Map();
        p["attributes"].forEach((ak, av){
          primitive.attributes[ak] = _resources[av];
        });
        return primitive;
      }, growable: false);
      _resources[k] = mesh;
    });
    return true;
  }
  
  handleCameras(description) {
    description.forEach((k, v) {
      var camera = new PerspectiveCamera(0.0);
      camera.fov = v["perspective"]["yfov"].toDouble();
      camera.far = v["perspective"]["zfar"].toDouble();
      camera.near = v["perspective"]["znear"].toDouble();
      _resources[k] = camera;
    });
    return true;
  }
  
  handleLights(description) {
    return true;
  }
  
  handleSkins(description) {
    return true;
  }
  
  handleNodes(Map description) {
    description.forEach((k, v){
      if(v["light"] != null) {
        var light = new Light();
        light.applyMatrix(_newMatrix4FromArray(v["matrix"]));
        _resources[k] = light;
      } else if(v["camera"] != null) {
        var camera = _resources[v["camera"]];
        camera.applyMatrix(_newMatrix4FromArray(v["matrix"]));
        _resources[k] = camera;
      } else {
        var node = new Node();
        node.name = v["name"];
        node.childNames = v["children"];
        node.applyMatrix(_newMatrix4FromArray(v["matrix"]));
        var meshes = v["meshes"];
        if(meshes != null) {
          node.meshes = new List.generate(meshes.length, (i){
            return _resources[meshes[i]];
          }, growable: false);
        }else{
          node.meshes = new List(0);
        }
        _resources[k] = node;
      }
    });
    return true;
  }
  
  handleScenes(Map description) {
    var json = description.values.first;
    if(json != null) {
      _scene = new Scene();
      _scene.resources = _resources;
      _scene.nodes = new List();
      json["nodes"].forEach((name){
        var node = _resources[name];
        if(node != null) {
          if (node is Camera) {
            _scene.camera = node;
          } else if(node is Light) {
            //TODO : light
          } else if(node is Node) {
            _scene.nodes.add(node);
          }
        }
      });
      _scene.nodes.forEach((node) => _buildNodeHirerachy(node));
      return true;
    }else{
      return false;
    }
  }
  
  handleAnimations(description) {
    return true;
  }

  _buildNodeHirerachy(Node node) {
    if(node.children == null)
      node.children = new List();
    node.childNames.forEach((name){
      var child = _resources[name];
      node.add(child);
      _buildNodeHirerachy(child);
    });
  }
  
  Matrix4 _newMatrix4FromArray(List arr) {
    return new Matrix4(
        arr[0].toDouble(), arr[1].toDouble(), arr[2].toDouble(), arr[3].toDouble(),
        arr[4].toDouble(), arr[5].toDouble(), arr[6].toDouble(), arr[7].toDouble(),
        arr[8].toDouble(), arr[9].toDouble(), arr[10].toDouble(), arr[11].toDouble(),
        arr[12].toDouble(), arr[13].toDouble(), arr[14].toDouble(), arr[15].toDouble());
  }

}













