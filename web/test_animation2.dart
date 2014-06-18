import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';


class TestAnimation2 {

  run() {
    var canvas = html.querySelector("#container");
    var renderer = new Renderer2(canvas);
    var director = new Director(renderer);
    director.replace(new MyScene(new PerspectiveCamera(canvas.width / canvas.height)));
    director.run();
  }
}

class MyScene extends Scene {
  MyScene(PerspectiveCamera camera) : super(camera);
  Mesh mesh;

  @override
  enter() {
    camera.position.setValues(0.0, 2.0, 4.0);
    camera.lookAt(new Vector3.zero());
    var url = "http://127.0.0.1:3030/orange/models/ogre/alric.orange";
    var loader = new OgreLoader();
    loader.load(renderer.ctx, url).then((m) {
      m.position.setValues(0.0, -1.0, 0.0);
      m.animator.switchAnimation("Idle");
      var controllers = html.querySelector("#controllers");
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
      nodes.add(m);
      mesh = m;
    });

    var plane = new Plane(width: 10, height: 10);
    plane.rotation.rotateX(-PI / 2);
    plane.position.setValues(0.0, -1.0, 0.0);
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    nodes.add(plane);
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
    // TODO: implement exit
  }

  @override
  update(num elapsed, num interval) {
    super.update(elapsed, interval);
  }
}
