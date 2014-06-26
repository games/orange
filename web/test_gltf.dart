part of orange_examples;



class TestGLTFScene extends Scene {

  TestGLTFScene(Camera camera) : super(camera);

  List _meshes = [];

  @override
  void enter() {

    var urls = ["../models/duck/duck.json", "../models/SuperMurdoch/SuperMurdoch.json", "../models/rambler/rambler.json", 
                "../models/wine/wine.json", "../models/axe/axe.json", "../models/veneno/veneno.json"];

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
    var loader = new GltfLoader2();
    loader.load(graphicsDevice.ctx, url).then((root) {
      _meshes.forEach((m) => remove(m));

      add(root);
      root.scale(0.1);
      root.showBoundingBox = true;
      root.updateMatrix();
      var min = new Vector3.all(double.MAX_FINITE);
      var max = new Vector3.all(-double.MAX_FINITE);
      var bounding = root.boundingInfo;
      if (bounding != null) {
        Vector3.min(min, bounding.boundingBox.minimumWorld, min);
        Vector3.max(max, bounding.boundingBox.maximumWorld, max);
      }
      var combina;
      combina = (child) {
        if (child is Mesh) {
          bounding = child.boundingInfo;
          if (bounding != null) {
            Vector3.min(min, bounding.boundingBox.minimumWorld, min);
            Vector3.max(max, bounding.boundingBox.maximumWorld, max);
          }
        }
        child.children.forEach(combina);
      };
      root.children.forEach(combina);
      root.boundingInfo = new BoundingInfo(min, max);
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
