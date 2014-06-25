library orange_examples;

import 'dart:html' as html;
import 'dart:math';
import 'dart:async';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'package:vector_math/vector_math.dart';

part 'test_boundingbox.dart';
part 'test_physics.dart';
part 'test_animation.dart';
part 'test_lighting.dart';
part 'test_gltf.dart';
part 'test_textures.dart';
part 'test_water.dart';




void main() {
  var canvas = html.querySelector("#container");
  var renderer = new GraphicsDevice(canvas);
  var camera = new PerspectiveCamera(canvas.width / canvas.height, near: 1.0, far: 2000.0);
  camera.translate(0.0, 0.0, 4.0);
  var controls = new OrbitControls();
  controls.attach(camera, canvas);

  var stats = new Stats();
  html.document.body.children.add(stats.container);

  var director = new Director(renderer);
  
  var scenes = [new TestAnimationScene(camera), 
                new TestBoundingBoxScene(camera), 
                new TestLightingScene(camera), 
                new PhysicsScene(camera),
                new TestGLTFScene(camera),
                new TestTexturesScene(camera),
                new TestWaterScene(camera)];
  var i = 6;
  
  director.replace(scenes[i]);
  director.run();
  director.afterRenders.add(() {
    stats.end();
    stats.begin();
  });

  var controllers = html.querySelector("#controllers");
  var selector = html.querySelector("#scenes") as html.SelectElement;
  selector.selectedIndex = i;
  selector.onChange.listen((e) {
    controllers.children.clear();
    director.replace(scenes[int.parse(selector.value)]);
  });

}










