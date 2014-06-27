part of orange;




// https://github.com/BabylonJS/Babylon.js/wiki/Babylon.js-file-format
// http://www.babylonjs.com/cyos/acpr/#M1XTA
class BabylonLoader {

  GraphicsDevice _device;
  gl.RenderingContext _ctx;
  Uri _uri;
  Map<String, dynamic> _resources;

  Future<Scene> load(GraphicsDevice device, String url, [Scene scene]) {
    _device = device;
    _ctx = _device.ctx;
    _uri = Uri.parse(url);
    _resources = {};
    if (scene == null) scene = new Scene();
    var completer = new Completer<Scene>();
    html.HttpRequest.getString(url).then((rsp) {
      var json = JSON.decode(rsp);
      completer.complete(_parse(json, scene));
    });
    return completer.future;
  }

  Scene _parse(Map json, Scene scene) {
    scene.autoClear = json["autoClear"];
    scene.backgroundColor = new Color.fromList(json["clearColor"]);
    scene.ambientColor = new Color.fromList(json["ambientColor"]);
    scene._gravity = _newVec3FromList(json["gravity"]);

    var cameras = _parseCamera(json);
    scene.camera = cameras[json["activeCamera"]];

    var lights = _parseLights(json);
    lights.forEach(scene.add);

    _parseMaterials(json);

    _parseGeometries(json);

    var meshes = _parseMeshes(json, scene);
    _buildHierarchy(meshes);
    meshes.forEach(scene.add);

    _parseShadowMaps(json);


    return scene;
  }

  void _buildHierarchy(List<Mesh> meshes) {
    meshes.forEach((mesh) {
      var data = _resources["Mesh_${mesh.id}"];
      var parentId = data["parentId"];
      if (parentId != null) {
        var parent = _resources["Mesh_${parentId}"]["mesh"] as Mesh;
        parent.add(mesh);
      }
    });
  }

  List<Mesh> _parseMeshes(Map json, Scene scene) {
    var meshes = [];
    json["meshes"].forEach((Map m) {
      var mesh = new Mesh();
      mesh.id = m["id"];
      mesh.position = _newVec3FromList(m["position"]);
      if (m.containsKey("rotation")) {
        mesh.rotation = _newQuatFromEuler(m["rotation"]);
      } else if (m.containsKey("rotationQuaternion")) {
        mesh.rotation = _newQuatFromList(m["rotationQuaternion"]);
      }
      mesh.scaling = _newVec3FromList(m["scaling"]);
      // TODO localMatrix, pivotMatrix, infiniteDistance, showSubMeshesBoundingBox, isVisible, pickable
      mesh.showBoundingBox = or(m["showBoundingBox"], false);
      mesh.receiveShadows = or(m["receiveShadows"], false);
      if (m.containsKey("physicsImpostor")) {
        if (!scene.physicsEnabled) scene.enablePhysics();
        mesh.physicsMass = or(m["physicsMass"], 0.0).toDouble();
        mesh.physicsFriction = or(m["physicsFriction"], 0.0);
        mesh._physicImpostor = or(m["physicsImpostor"], 0);
        if (mesh._physicImpostor != PhysicsEngine.NoImpostor) {
          var options = new PhysicsBodyCreationOptions(restitution: mesh.physicsRestitution, friction: mesh.physicsFriction, mass: mesh.physicsMass);
          mesh.setPhysicsState(mesh._physicImpostor, options);
        }
      }

      mesh.visibility = or(m["visibility"], 1.0).toDouble();
      if (m.containsKey("geometryId")) {
        mesh.geometry = _resources["Geometry_${m["geometryId"]}"];
      } else {
        mesh.geometry = _parseGeometry(m);
      }
      if (m.containsKey("materialId")) {
        mesh.material = _resources["Material_${m["materialId"]}"];
      }
      // TODO animations
      _resources["Mesh_${mesh.id}"] = {
        "parent": m["parentId"],
        "mesh": mesh
      };
      meshes.add(mesh);
    });
    return meshes;
  }

  void _parseGeometries(Map json) {
    if (json.containsKey("geometries")) {
      var geometries = json["geometries"];
      geometries["vertexData"].forEach((Map vd) {
        var v = _parseGeometry(vd);
        _resources["Geometry_${v.id}"] = v;
      });
    }
  }

  Geometry _parseGeometry(Map desc) {
    var geometry = new Geometry();
    if (desc["id"] != null) geometry.id = desc["id"];
    if (desc["positions"] != null) geometry.positions = _toFloat32List(desc["positions"]);
    if (desc["normals"] != null) geometry.normals = _toFloat32List(desc["normals"]);
    if (desc["uvs"] != null) geometry.texCoords = _toFloat32List(desc["uvs"]);
    if (desc["uv2s"] != null) geometry.texCoords2 = _toFloat32List(desc["uv2s"]);
    // TODO colors, matricesIndices, matricesWeights
    if (desc["indices"] != null) geometry.indices = new Uint16List.fromList(desc["indices"]);
    return geometry;
  }

  _parseMaterials(Map json) {
    json["materials"].forEach((Map m) {
      var material = new StandardMaterial();
      material.id = m["id"];
      material.ambientColor = new Color.fromList(m["ambient"]);
      material.diffuseColor = new Color.fromList(m["diffuse"]);
      material.specularColor = new Color.fromList(m["specular"]);
      material.specularPower = m["specularPower"].toDouble();
      material.emissiveColor = new Color.fromList(m["emissive"]);
      material.backFaceCulling = or(m["backFaceCulling"], true);
      material.wireframe = or(m["wireframe"], false);
      material.alpha = m["alpha"].toDouble();
      material.diffuseTexture = _parseTexture(m["diffuseTexture"]);
      material.ambientTexture = _parseTexture(m["ambientTexture"]);
      material.opacityTexture = _parseTexture(m["opacityTexture"]);
      material.reflectionTexture = _parseTexture(m["reflectionTexture"]);
      material.emissiveTexture = _parseTexture(m["emissiveTexture"]);
      material.specularTexture = _parseTexture(m["specularTexture"]);
      material.bumpTexture = _parseTexture(m["bumpTexture"]);
      _resources["Material_" + material.id] = material;
    });
  }

  Texture _parseTexture(Map desc) {
    if (desc == null) return null;
    var url = _uri.resolve(desc["name"]).toString();
    if (Texture._texturesCache.containsKey(url)) return Texture._texturesCache[url];

    var texture;
    if (desc["isCube"] == true) {
      texture = new CubeTexture(url);
    } else if (desc["isRenderTarget"] == true) {
      var size = desc["renderTargetSize"].toDouble();
      texture = new RenderTargetTexture(_device, size, size);
    } else if (desc["mirrorPlane"] != null) {
      var size = desc["renderTargetSize"].toDouble();
      texture = new MirrorTexture(_device, size, size);
    } else {
      texture = Texture.load(_ctx, {
        "path": url,
        "flip": true
      });
    }
    texture.level = desc["level"].toDouble();
    texture.hasAlpha = or(desc["hasAlpha"], false);
    texture.coordinatesMode = desc["coordinatesMode"];
    if (texture is CubeTexture) return texture;

    texture.getAlphaFromRGB = or(desc["getAlphaFromRGB"], false);
    texture.uOffset = desc["uOffset"].toDouble();
    texture.vOffset = desc["vOffset"].toDouble();
    texture.uScale = desc["uScale"].toDouble();
    texture.vScale = desc["vScale"].toDouble();
    texture.uAng = desc["uAng"].toDouble();
    texture.vAng = desc["vAng"].toDouble();
    texture.wrapU = desc["wrapU"].toDouble();
    texture.wrapV = desc["wrapV"].toDouble();
    texture.coordinatesIndex = desc["coordinatesIndex"];
    return texture;
  }

  void _parseShadowMaps(Map json) {
    if (json["shadowGenerators"] != null) {
      json["shadowGenerators"].forEach((s) {
        var light = _resources["Light_${s["lightId"]}"] as Light;
        if (light != null && light is DirectionalLight) {
          light.shadowRenderer = new ShadowRenderer(s["mapSize"], light, _device);
          light.shadowRenderer.useVarianceShadowMap = s["useVarianceShadowMap"];
          // TODO fixme
          //          s["renderList"].forEach((mid) {
          //            var m = _resources["Mesh_${mid}"];
          //            if (m != null) {
          //              (m["mesh"] as Mesh).receiveShadows = true;
          //            }
          //          });
        }
      });
    }
  }

  //int (0 for point light, 1 for directional, 2 for spot and 3 for hemispheric),
  List<Light> _parseLights(Map json) {
    var lights = [];
    json["lights"].forEach((l) {
      var light;
      int type = l["type"].toInt();
      if (type == 0) {
        light = new PointLight(0x0);
      } else if (type == 1) {
        light = new DirectionalLight(0x0);
        light.direction = _newVec3FromList(l["direction"]);
      } else if (type == 2) {
        light = new SpotLight(0x0);
        light.angle = l["angle"].toDouble();
        light.exponent = l["exponent"].toDouble();
      } else if (type == 3) {
        return;
      }
      light.id = l["id"];
      light.position = _newVec3FromList(l["position"]);
      light.intensity = l["intensity"].toDouble();
      light.diffuse = new Color.fromList(l["diffuse"]);
      light.specular = new Color.fromList(l["specular"]);
      lights.add(light);
      _resources["Light_${light.id}"] = light;
    });
    return lights;
  }

  Map<String, Camera> _parseCamera(Map json) {
    var cameras = {};
    var aspect = _ctx.canvas.width / _ctx.canvas.height;
    json["cameras"].forEach((c) {
      var camera = new PerspectiveCamera(aspect, near: c["minZ"].toDouble(), far: c["maxZ"].toDouble(), fov: c["fov"].toDouble());
      camera.position = _newVec3FromList(c["position"]);
      if (c["target"] != null) {
        camera.lookAt(_newVec3FromList(c["target"]));
      }
      // TODO speed, inertia, checkCollisions, applyGravity, ellipsoid
      cameras[c["name"]] = camera;
    });
    return cameras;
  }


}
