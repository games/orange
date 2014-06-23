import 'package:orange/orange.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:html';



class TestGLTFScene extends Scene {

  TestGLTFScene(Camera camera) : super(camera);

  List _meshes = [];

  @override
  void enter() {

    //    camera.position.setValues(-20.0, 2600.0, 1000.0);
    //    camera.position.setValues(100.0, 100.0, 300.0);
    camera.lookAt(new Vector3.zero());

    var urls = ["../models/duck/duck.json", "../models/SuperMurdoch/SuperMurdoch.json", "../models/rambler/rambler.json", "../models/wine/wine.json", "../models/axe/axe.json"];

    var selector = new SelectElement();
    urls.forEach((u) {
      var option = new OptionElement(data: u.split("/").last, value: u);
      selector.children.add(option);

    });
    selector.onChange.listen((e) {
      var opt = selector.options[selector.selectedIndex];
      _loadModel(opt.value);
    });
    querySelector("#controllers").children.add(selector);

    _loadModel(urls.first);

    var light0 = new PointLight(0xffffff);
    light0.intensity = 0.9;
    light0.position = new Vector3(-100.0, 300.0, 3000.0);
    add(light0);

    var light1 = new DirectionalLight(0xffffff);
    light1.intensity = 0.2;
    light1.specular = new Color.fromHex(0xffffff);
    light1.position = new Vector3(100.0, 300.0, 300.0);
    light1.direction = new Vector3(-1.0, -1.0, 0.0).normalize();
    add(light1);
  }

  void _loadModel(String url) {
    var loader = new GltfLoader2();
    loader.load(graphicsDevice.ctx, url).then((nodes) {
      _meshes.forEach((m) => remove(m));

      // TODO fix me
      Mesh root;
      nodes.forEach((node) {
        root = node;
        add(node);
      });
      var min = root.boundingInfo.boundingBox.minimumWorld;
      var max = root.boundingInfo.boundingBox.maximumWorld;
      root.position.setValues(-(max.x + min.x) / 2.0, -(max.y + min.y) / 2.0, -(max.z + min.z) / 2.0);
      _meshes = nodes;
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
