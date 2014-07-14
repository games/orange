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
    // fog
    if (json["fogMode"] != null && json["fogMode"] != 0) {
      scene.fogMode = json["fogMode"];
      scene.fogColor = new Color.fromList(json["fogColor"]);
      scene.fogStart = json["fogStart"];
      scene.fogEnd = json["fogEnd"];
      scene.fogDensity = json["fogDensity"];
    }

    _parseLights(json).forEach(scene.add);

    _parseMaterials(json);

    _parseGeometries(json);

    _buildHierarchy(_parseMeshes(json, scene)).forEach(scene.add);

    var cameras = _parseCamera(json);
    scene.camera = cameras[json["activeCameraID"]];
    scene.cameras = cameras;

    _parseShadowMaps(json);

    // TODO skeletons
    _parseSkeletons(json);

    scene._particleSystemds = _parseParticleSystems(json, scene);

    // lensFlareSystems

    return scene;
  }

  List<Mesh> _buildHierarchy(List<Mesh> meshes) {
    var roots = [];
    meshes.forEach((mesh) {
      var data = _resources["Mesh_${mesh.id}"];
      var parentId = data["parentId"];
      if (parentId != null) {
        var parent = _resources["Mesh_${parentId}"]["mesh"] as Mesh;
        parent.add(mesh);
      } else {
        roots.add(mesh);
      }
    });
    return roots;
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
      // TODO localMatrix, pivotMatrix, infiniteDistance, pickable
      if (m["localMatrix"] != null) {
        mesh._pivotMatrix = _newMatrix4FromList(m["localMatrix"]);
      } else if (m["pivotMatrix"] != null) {
        mesh._pivotMatrix = _newMatrix4FromList(m["pivotMatrix"]);
      }
      mesh.enabled = or(m["isEnabled"], true);
      mesh.visible = m["isVisible"];
      mesh.showBoundingBox = or(m["showBoundingBox"], false);
      mesh.showSubBoundingBox = or(m["showSubMeshesBoundingBox"], false);
      mesh.receiveShadows = or(m["receiveShadows"], false);
      mesh.billboardMode = m["billboardMode"];
      if (m["physicsImpostor"] != null) {
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
      } else if (m["delayLoadingFile"] != null) {
        _delayLoading(mesh, m);
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
  
  void _delayLoading(Mesh mesh, Map desc) {
    var url = _uri.resolve(desc["delayLoadingFile"]).toString();
    html.HttpRequest.request(url).then((r) {
      var json = JSON.decode(r.responseText);
      mesh.geometry = _parseGeometry(json);
    });
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
      material.backFaceCulling = or(m["backFaceCulling"], false);
      material.wireframe = or(m["wireframe"], false);
      material.diffuseTexture = _parseTexture(m["diffuseTexture"]);
      material.ambientTexture = _parseTexture(m["ambientTexture"]);
      material.opacityTexture = _parseTexture(m["opacityTexture"]);
      material.reflectionTexture = _parseTexture(m["reflectionTexture"]);
      material.emissiveTexture = _parseTexture(m["emissiveTexture"]);
      material.specularTexture = _parseTexture(m["specularTexture"]);
      material.bumpTexture = _parseTexture(m["bumpTexture"]);
      material.alpha = m["alpha"].toDouble();
      if(material.alpha < 1.0) {
        material.technique.pass.blending = true;
        material.technique.pass.alphaMode = 1;
      }
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
      var size = desc["renderTargetSize"].toInt();
      texture = new RenderTargetTexture(_device, size, size);
    } else if (desc["mirrorPlane"] != null) {
      var size = desc["renderTargetSize"].toDouble();
      texture = new MirrorTexture(_device, size, size);
      texture.mirrorPlane = _newPlaneFromList(desc["mirrorPlane"]);
    } else {
      texture = Texture.load(_ctx, {
        "path": url,
        "flip": true
      });
    }
    texture.name = desc["name"];
    texture.level = desc["level"].toDouble();
    texture.hasAlpha = or(desc["hasAlpha"], false);
    texture.coordinatesMode = desc["coordinatesMode"];
    if (texture is CubeTexture) return texture;

    texture.coordinatesIndex = desc["coordinatesIndex"];
    texture.getAlphaFromRGB = or(desc["getAlphaFromRGB"], false);
    texture.uOffset = desc["uOffset"].toDouble();
    texture.vOffset = desc["vOffset"].toDouble();
    texture.uScale = desc["uScale"].toDouble();
    texture.vScale = desc["vScale"].toDouble();
    texture.uAng = desc["uAng"].toDouble();
    texture.vAng = desc["vAng"].toDouble();
    texture.wrapU = desc["wrapU"].toDouble();
    texture.wrapV = desc["wrapV"].toDouble();
    // TODO animations of texture
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
        light.direction = _newVec3FromList(l["direction"]);
        light.angle = l["angle"].toDouble();
        light.exponent = l["exponent"].toDouble();
      } else if (type == 3) {
        light = new HemisphericLight(0x0);
        light.direction = _newVec3FromList(l["direction"]);
        light.groundColor = new Color.fromList(l["groundColor"]);
      }
      light.id = l["id"];
      if (l["position"] != null) light.position = _newVec3FromList(l["position"]);
      if (l["intensity"] != null) light.intensity = l["intensity"].toDouble();
      if (l["range"] != null) light.range = l["range"].toDouble();
      light.diffuse = new Color.fromList(l["diffuse"]);
      light.specular = new Color.fromList(l["specular"]);
      // TODO animation of light
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
      camera.id = c["id"];
      camera.name = c["name"];
      camera.position = _newVec3FromList(c["position"]);
      if (c["target"] != null) {
        camera.lookAt(_newVec3FromList(c["target"]));
      } else {
        // TODO fixme
        var quat = new Quaternion.identity();
        quat.setEuler(c["rotation"][1].toDouble(), c["rotation"][0].toDouble(), c["rotation"][2].toDouble());
        camera.rotation = quat;
        camera.lookAtFromRotation();
      }
      if (c["parentId"] != null) {
        var parent = _resources["Mesh_${c["parentId"]}"] as Node;
        parent.add(camera);
      }
      // TODO speed, inertia, checkCollisions, applyGravity, ellipsoid
      cameras[c["id"]] = camera;
    });
    return cameras;
  }

  _parseSkeletons(Map root) {
    if (root["skeletons"] != null) {

    }
  }

  List<ParticleSystem> _parseParticleSystems(Map json, Scene scene) {
    var list = json["particleSystems"];
    if (list == null) return [];

    var result = [];
    list.forEach((Map sys) {
      var emitter = _resources["Mesh_${sys["emitterId"]}"]["mesh"];
      var particleSystem = new ParticleSystem("particle#${sys["emitterId"]}", sys["capacity"], scene);
      if (sys["textureName"] != null) {
        particleSystem.particleTexture = Texture.load(_ctx, {
          "path": _uri.resolve(sys["textureName"]).toString(),
          "flip": true
        });
      }
      particleSystem.minAngularSpeed = sys["minAngularSpeed"].toDouble();
      particleSystem.maxAngularSpeed = sys["maxAngularSpeed"].toDouble();
      particleSystem.minSize = sys["minSize"].toDouble();
      particleSystem.maxSize = sys["maxSize"].toDouble();
      particleSystem.minLifeTime = sys["minLifeTime"].toDouble();
      particleSystem.maxLifeTime = sys["maxLifeTime"].toDouble();
      particleSystem.emitter = emitter;
      particleSystem.emitRate = sys["emitRate"].toDouble();
      particleSystem.minEmitBox = _newVec3FromList(sys["minEmitBox"]);
      particleSystem.maxEmitBox = _newVec3FromList(sys["maxEmitBox"]);
      particleSystem.gravity = _newVec3FromList(sys["gravity"]);
      particleSystem.direction1 = _newVec3FromList(sys["direction1"]);
      particleSystem.direction1 = _newVec3FromList(sys["direction1"]);
      particleSystem.color1 = new Color.fromList(sys["color1"]);
      particleSystem.color2 = new Color.fromList(sys["color2"]);
      particleSystem.colorDead = new Color.fromList(sys["colorDead"]);
      particleSystem.updateSpeed = sys["updateSpeed"].toDouble();
      particleSystem.targetStopDuration = sys["targetStopFrame"].toDouble();
      particleSystem.textureMask = new Color.fromList(sys["textureMask"]);
      particleSystem.blendMod = sys["blendMode"];
      result.add(particleSystem);
    });
    return result;
  }


}
