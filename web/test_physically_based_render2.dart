part of orange_examples;




class TestPhysicallyBasedRender2 extends Scene {
  TestPhysicallyBasedRender2(Camera camera) : super(camera);

  @override
  void enter() {
    var urls = [{
        "path": "models/obj/Head_max_obj/Infinite-Level_02.obj",
        "diffuse": "models/obj/Head_max_obj/Images/Map-COL.jpg",
        "bump": "models/obj/Head_max_obj/Images/Infinite-Level_02_Tangent_SmoothUV2.jpg",
        "flip": true,
        "loader": "OBJ"
      }];

    _loadOBJModel(urls.first);
  }

  void _loadOBJModel(Map desc) {
    var url = desc["path"];
    var diffuse = desc["diffuse"];
    var bump = desc["bump"];
    var flip = desc["flip"];
    var loader = new ObjLoader();
    loader.load(url).then((m) {
      removeChildren();
      add(m);
      var diffuseTexture = Texture.load(graphicsDevice.ctx, {
        "path": diffuse,
        "flip": flip
      });
      Texture bumpTexture;
      if (bump != null) {
        bumpTexture = Texture.load(graphicsDevice.ctx, {
          "path": bump,
          "flip": flip
        });
      }
      var material = new PhysicallyBasedMaterial();
      material.diffuseTexture = diffuseTexture;
      material.bumpTexture = bumpTexture;
      m.material = material;
      
      _forceOn(m);
    });
  }

  void _forceOn(Mesh mesh) {
    var box = mesh.boundingInfo.boundingBox;
    var radius = mesh.boundingInfo.boundingSphere.radius;
    camera.position = box.center + new Vector3(0.0, radius * 0, radius * 2);
    camera.lookAt(box.center);
  }

  @override
  exit() {
    dispose();
  }
}
