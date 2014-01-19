import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';


class TestLighting {
  double _lastElapsed = 0.0;
  Renderer renderer;
  Pass pass;
  List<Mesh> meshes = [];
  Stats stats;

  Light _directionalLight;
  Light _pointLight;
  Light _spotLight;
  
  
  run() {
    stats = new Stats();
    html.document.body.children.add(stats.container);
    
    var canvas = html.querySelector("#container");
    renderer = new Renderer(canvas);
    renderer.camera.center = new Vector3(0.0, 0.0, 0.0);
    renderer.pass = new Pass();
    renderer.pass.shader = new Shader(renderer.ctx, simpleModelVS, simpleModelFS);
    
    var cube = new Cube(0.5, 0.5, 0.5);
    cube.position.setValues(-1.0, 0.0, 0.0);
    meshes.add(cube);
    
    var sphere = new Sphere(32, 32, 0.5);
    sphere.position.setValues(1.0, 0.0, 0.0);
    meshes.add(sphere);
    
    var plane = new Plane(2.0, 2.0);
    meshes.add(plane);
    
    html.window.requestAnimationFrame(_animate);
  }


  _animate(num elapsed) {
    var interval = elapsed - _lastElapsed;
    stats.begin();
    
    renderer.camera.update(interval);
    renderer.prepare();
    meshes.forEach((m) => renderer.draw(m));

    stats.end();
    _lastElapsed = elapsed;
    html.window.requestAnimationFrame(_animate);
  }
}























