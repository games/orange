part of orange_examples;



class TestGLTFScene extends Scene {

  TestGLTFScene(Camera camera) : super(camera);

  List _meshes = [];
  bool _showBBox = false;

  @override
  void enter() {

    var urls = ["models/gltf/monster/monster.json", "models/gltf/keeper_of_the_light/keeper_of_the_light.json", 
                "models/gltf/duck/duck.json", "models/gltf/SuperMurdoch/SuperMurdoch.json",
                "models/gltf/rambler/rambler.json", "models/gltf/wine/wine.json", "models/gltf/marauder/marauder.json", 
                "models/gltf/monk_male/monk_male.json"];

    var selector = new html.SelectElement();
    urls.forEach((u) {
      var option = new html.OptionElement(data: u.split("/").last, value: u);
      selector.children.add(option);

    });
    selector.onChange.listen((e) {
      var opt = selector.options[selector.selectedIndex];
      _loadModel(opt.value);
    });

    html.querySelector("#controllers").children.add(selector);

    var toggleBoundingBox = new html.ButtonElement();
    toggleBoundingBox.onClick.listen((e) {
      _meshes.forEach((m) {
        _showBBox = !_showBBox;
        m.showBoundingBox = _showBBox;
        m.showSubBoundingBox = _showBBox;
      });
    });
    toggleBoundingBox.text = "Bounding Box";
    html.querySelector("#controllers").children.add(toggleBoundingBox);

    _loadModel(urls.first);

    var light0 = new PointLight(0xffffff);
    light0.intensity = 0.9;
    light0.translate(-100.0, 300.0, 3000.0);
    add(light0);

    var light1 = new DirectionalLight(0xffffff);
    light1.intensity = 0.2;
    light1.specular = new Color.fromHex(0xffffff);
    light1.translate(100.0, 300.0, 300.0);
    light1.direction = new Vector3(-1.0, -1.0, 0.0).normalize();
    add(light1);
  }

  void _loadModel(String url) {
    var loader = new GltfLoader();
    loader.load(graphicsDevice.ctx, url).then((root) {
      _meshes.forEach((m) => remove(m));
      _meshes.clear();

      add(root);
      root.showBoundingBox = _showBBox;
      root.showSubBoundingBox = _showBBox;
      root.updateMatrix();
      root.boundingInfo = BoundingInfo.compute([root]);
      var box = root.boundingInfo.boundingBox;
      var radius = root.boundingInfo.boundingSphere.radius;
      camera.position = box.center + new Vector3(0.0, radius, radius * 3);
      camera.lookAt(box.center);

      _meshes.add(root);
    });
  }

  @override
  void enterFrame(num elapsed, num interval) {
  }

  @override
  void exit() {
    super.exit();
    removeChildren();
  }
}
