import 'dart:html' as html;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'package:vector_math/vector_math.dart';
import 'show_boundingbox.dart';
import 'test_physics.dart';
import 'test_animation.dart';
import 'test_renderer.dart';




void main() {
  var canvas = html.querySelector("#container");
  var renderer = new GraphicsDevice(canvas);
  var camera = new PerspectiveCamera(canvas.width / canvas.height);
  camera.position.setValues(0.0, 2.0, 4.0);
  camera.lookAt(new Vector3.zero());

  var stats = new Stats();
  html.document.body.children.add(stats.container);

  var director = new Director(renderer);
  director.replace(new TestAnimationScene(camera));
  director.run();
  director.afterRenders.add(() {
    stats.end();
    stats.begin();
  });

  var controllers = html.querySelector("#controllers");

  var scenes = [new TestAnimationScene(camera), new ShowBoundingBoxScene(camera), new TestLightingScene(camera), new PhysicsScene(camera)];
  var selector = html.querySelector("#scenes") as html.SelectElement;
  selector.onChange.listen((e) {
    controllers.children.clear();
    director.replace(scenes[int.parse(selector.value)]);
  });

}










