import 'dart:html';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';

void main() {

  initOrange(query('#container'));
  
  var scene = new TestScene();
  
  scene.camera = new PerspectiveCamera();
  scene.camera.position.z = 10.0;
  
  director.replace(scene);
  director.run();
  
}

class TestScene extends Scene {

  Stats _stats;
  
  enter() {
    _stats = new Stats();
    document.body.append(_stats.container);
    
    var cube = new Cube(0.5, 0.5, 0.5);
    cube.position.setValues(-1.0, 0.0, -5.0);
    add(cube);

    
    var sphere = new Sphere(1.0, 32, 32);
    sphere.position.setValues(1.0, 0.0, -5.0);
    add(sphere);
  }
  
  update(double elapsed) {
    _stats.begin();
    
    children.forEach((e) {
      e.rotation.x += 1.0 * elapsed % 3.14;
      e.rotation.y += 1.0 * elapsed % 3.14;
      e.rotation.z += 1.0 * elapsed % 3.14;
    });
  }
  
  render() {
    super.render();
    _stats.end();
  }
}
