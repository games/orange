import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';


class TestNewRenderer {

  run() {
    var canvas = html.querySelector("#container");
    var renderer = new Renderer2(canvas);
    var director = new Director(renderer);
    director.replace(new MyScene(new PerspectiveCamera(canvas.width / canvas.height)));
    director.run();
  }
}


class MyScene extends Scene {

  MyScene(PerspectiveCamera camera): super(camera);

  @override
  enter() {
    camera.position.setValues(0.0, 2.0, 5.0);
    camera.lookAt(new Vector3.zero());

    var box = new Cube();
    box.position.setValues(0.0, 0.0, 0.0);
    box.material = new StandartMaterial(director.renderer);
    nodes.add(box);
  }

  @override
  update(num elapsed, num interval) {
    camera.update(interval);
    camera.position.setValues(cos(elapsed / 1000) * 5, 2.0, sin(elapsed / 1000) * 5);
    camera.lookAt(new Vector3.zero());
  }

}
