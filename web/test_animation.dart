part of orange_examples;




class TestAnimationScene extends Scene {
  TestAnimationScene(Camera camera) : super(camera);
  Mesh mesh;
  bool rotateCamera = false;

  @override
  enter() {

    var controllers = html.querySelector("#controllers");
    camera.setTranslation(0.0, 1.0, 2.5);
    camera.lookAt(new Vector3(0.0, 0.4, 0.0));

    var url = "http://127.0.0.1:3030/orange/models/ogre/alric.orange";
    var loader = new OgreLoader();
    loader.load(graphicsDevice.ctx, url).then((m) {
      m.setTranslation(0.0, -1.0, -1.0);
      m.animator.switchAnimation("Idle");
      m.animator.animations.forEach((n, a) {
        var row = new html.DivElement();
        row.className = "row";
        var radio = _createAnimationSelector(n, a);
        var label = new html.LabelElement();
        label.htmlFor = radio.id;
        label.text = n;
        row.children.add(radio);
        row.children.add(label);
        controllers.children.add(row);
      });
      add(m);
      m.receiveShadows = false;
      m.castShadows = true;
      m.showBoundingBox = true;
      mesh = m;
    });

    var row = new html.DivElement();
    row.className = "row";
    var radio = new html.CheckboxInputElement();
    radio.id = "rotate_camera";
    radio.name = "rotate_camera";
    radio.value = "rotate_camera";
    radio.onClick.listen((e) {
      rotateCamera = !rotateCamera;
    });
    var label = new html.LabelElement();
    label.htmlFor = radio.id;
    label.text = "Rotate Camera";
    row.children.add(radio);
    row.children.add(label);
    controllers.children.add(row);

    var light0 = new PointLight(0xffffff);
    light0.setTranslation(0.0, 1.0, 0.0);
    add(light0);

    var light2 = new HemisphericLight(0xffffff);
    add(light2);
  }

  html.RadioButtonInputElement _createAnimationSelector(String name, Animation animation) {
    var radio = new html.RadioButtonInputElement();
    radio.id = name;
    radio.name = "animation";
    radio.value = name;
    radio.onClick.listen((e) {
      mesh.animator.switchAnimation(name);
    });
    return radio;
  }

  @override
  exit() {
    super.exit();
    removeChildren();
  }

  num _elapsed = 0;

  @override
  enterFrame(num elapsed, num interval) {
    super.enterFrame(elapsed, interval);

    if (rotateCamera) {
      _elapsed += interval;
      camera.setTranslation(cos(_elapsed / 1000) * 4.0, 2.0, sin(_elapsed / 1000) * 4.0);
      //      camera.lookAt(new Vector3.zero());
    }
  }
}

