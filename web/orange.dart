import 'dart:html';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';

void main() {

  initOrange(query('#container'));
  
  var scene = new TestScene();
  
  scene.camera = new PerspectiveCamera();
  scene.camera.position.z = 4.0;
  
  director.replace(scene);
  director.run();
  
}

class TestScene extends Scene {

  Stats _stats;
  Cube cube;
  
  enter() {
    _stats = new Stats();
    document.body.append(_stats.container);
    
    cube = new Cube(0.5, 0.5, 0.5);
    cube.position.setValues(-1.0, 0.0, -5.0);
    add(cube);

    
    cube = new Cube(1.0, 1.0, 1.0);
    cube.position.setValues(1.0, 0.0, -5.0);
    add(cube);
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
