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
    
    cube = new Cube(1, 1, 1);
    cube.position.setValues(0.0, 0.0, -7.0);
    add(cube);
  }
  
  update(double elapsed) {
    _stats.begin();
    
    cube.rotation.x += 1.0 * elapsed % 3.14;
    cube.rotation.y += 1.0 * elapsed % 3.14;
    cube.rotation.z += 1.0 * elapsed % 3.14;
  }
  
  render() {
    super.render();
    _stats.end();
  }
}
