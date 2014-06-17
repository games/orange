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

  @override
  enter() {
    var url = "http://127.0.0.1:3030/orange/models/ogre/alric.orange";
    var loader = new OgreLoader();
    loader.load(renderer.ctx, url).then((m) {
      m.position.setValues(0.0, -1.0, 0.0);
      m.animator.switchAnimation("Idle");
      m.animator.animations.forEach((n, a) => print(n));
      nodes.add(m);
    });
  }

  @override
  exit() {
    // TODO: implement exit
  }

  @override
  update(num elapsed, num interval) {
    // TODO: implement update
  }
}
