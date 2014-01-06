part of orange;


class Loader {
  String _path;
  Uri _uri;
  Node _root;
  Resources _resources = new Resources();
  Map<String, Joint> _joints = {};

  Loader(this._path) {
    _uri = Uri.parse(_path);
  }
  
  Future start() {
    var completer = new Completer();
    html.HttpRequest.getString(_path)
      .then((rsp){
          if(_parse(JSON.decode(rsp))){
            completer.complete({"root": _root, "resources": _resources});
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
  
  handleSkins(Map description) {
    description.forEach((k, v) {
      var skin = new Skin();
      skin.bindShapeMatrix = _newMatrix4FromArray(v["bindShapeMatrix"]);
      skin.jointsIds = v["joints"];
      skin.inverseBindMatrices = new MeshAttribute();
      skin.inverseBindMatrices.bufferView = _resources[v["inverseBindMatrices"]["bufferView"]];
      skin.inverseBindMatrices.byteOffset = v["inverseBindMatrices"]["byteOffset"];
      skin.inverseBindMatrices.count = v["inverseBindMatrices"]["count"];
      skin.inverseBindMatrices.type = v["inverseBindMatrices"]["type"];
      skin.jointsForSkeleton = new Map();
      _resources[k] = skin;
    });
    return true;
  }
  
  handleNodes(Map description) {
    description.forEach((String k, Map v){
      var matrix;
      if(v.containsKey("matrix")) {
        matrix = _newMatrix4FromArray(v["matrix"]);
      } else {
        matrix = _newMatrix4FromSQT(v["scale"], v["rotation"], v["translation"]);
      }
      var node;
      if(v.containsKey("jointId")) {
        node = new Joint();
        node.id = v["jointId"];
        _joints[node.id] = node;
      }else if(v.containsKey("light")) {
        node = new Light();
      } else if(v.containsKey("camera")) {
        node = _resources[v["camera"]];
      } else {
        node = new Node();
        if(v.containsKey("meshes")) {
          var meshes = v["meshes"];
          node.meshes = new List.generate(meshes.length, (i){
            return _resources[meshes[i]];
          }, growable: false);
        } else if(v.containsKey("mesh")) {
          node.meshes = [_resources[v["mesh"]]];
        } else if (v.containsKey("instanceSkin")) {
          var instanceSkin = v["instanceSkin"];
          instanceSkin["skin"] = _resources[instanceSkin["skin"]];
          node.instanceSkin = instanceSkin;
          var source = instanceSkin["sources"];
          node.meshes = new List.generate(source.length, (i){
            return _resources[source[i]];
          }, growable: false);
        } else {
          node.meshes = new List(0);
        }
      }
      node.name = v["name"];
      node.childNames = v["children"];
      node.applyMatrix(matrix);
      _resources[k] = node;
    });
    return true;
  }
  
  handleScenes(Map description) {
    var json = description.values.first;
    if(json != null) {
      _root = new Node();
      json["nodes"].forEach((name){
        var node = _resources[name];
        if(node != null) {
          if (node is Camera) {
            
          } else if(node is Light) {
            //TODO : light
          } else if(node is Node) {
            _root.add(node);
          }
        }
      });
      _root.children.forEach((node) => _buildNodeHierarchy(node));
      _buildSkins(_root);
      return true;
    }else{
      return false;
    }
  }
  
  handleAnimations(description) {
    description.forEach((k, v){
            
    });
    return true;
  }

  _buildNodeHierarchy(Node node) {
    if(node.children == null)
      node.children = new List();
    node.childNames.forEach((name){
      var child = _resources[name];
      node.add(child);
      _buildNodeHierarchy(child);
    });
  }
  
  _buildSkins(Node node) {
    if(node.instanceSkin != null) {
      _buildSkin(node);
    }
    node.children.forEach((n) => _buildSkins(n));
  }
  
  _buildSkin(Node node) {
    Skin skin = node.instanceSkin["skin"];
    if(skin != null) {
      node.instanceSkin["skeletons"].forEach((skeleton) {
        var rootSkeleton = _resources[skeleton];
        if(rootSkeleton != null) {
          var jointsIds = skin.jointsIds;
          var joints = [];
          jointsIds.forEach((jointId) {
            //FIXME: should be use this one: var joint = rootSkeleton.nodeWithJointID(jointId);
            var joint = _joints[jointId];
            if(joint != null) 
              joints.add(joint);
          });
          skin.jointsForSkeleton[skeleton] = joints; 
        }
      });
      node.skin = skin;
    }
  }
  
  Matrix4 _newMatrix4FromArray(List arr) {
    if(arr.length != 16)
      return new Matrix4.identity();
    return new Matrix4(
        arr[0].toDouble(), arr[1].toDouble(), arr[2].toDouble(), arr[3].toDouble(),
        arr[4].toDouble(), arr[5].toDouble(), arr[6].toDouble(), arr[7].toDouble(),
        arr[8].toDouble(), arr[9].toDouble(), arr[10].toDouble(), arr[11].toDouble(),
        arr[12].toDouble(), arr[13].toDouble(), arr[14].toDouble(), arr[15].toDouble());
  }

  Matrix4 _newMatrix4FromSQT(List s, List r, List t) {
    var m = new Matrix4.zero();
    m.fromRotationTranslation(new Quaternion(r[0].toDouble(), r[1].toDouble(), r[2].toDouble(), r[3].toDouble()), 
        new Vector3(t[0].toDouble(), t[1].toDouble(), t[2].toDouble()));
    m.scale(s[0].toDouble(), s[1].toDouble(), s[2].toDouble());
    return m;
  }
}













