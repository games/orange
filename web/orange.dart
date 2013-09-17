import 'dart:html';
import 'dart:math';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'package:vector_math/vector_math.dart';

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
    
    var cube = new Cube(1.0, 1.0, 1.0);
    cube.position.setValues(-1.0, 0.0, 0.0);
    add(cube);

    
    var sphere = new Sphere(1.0, 32, 32);
    sphere.position.setValues(1.0, 0.0, 0.0);
    add(sphere);
  }
  var i = 0.0;
  update(double interval) {
    _stats.begin();
    
    if(director.keyboard.held(KeyCode.LEFT)){
//      camera.position += new Vector3(-0.1, 0.0, 0.0);
      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians + 0.01);
    }else if(director.keyboard.held(KeyCode.RIGHT)){
//      camera.position += new Vector3(0.1, 0.0, 0.0);
      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians - 0.01);
    }else if(director.keyboard.held(KeyCode.UP)){
      camera.position += camera.frontDirection * 0.1;
    }else if(director.keyboard.held(KeyCode.DOWN)){
      camera.position -= camera.frontDirection * 0.1;
    }
    
    var s = interval / 1000.0;

//    camera.lookAt(children[0].position);
      i += 1.0 * s % 3.14;
//    children[0].rotation.setAxisAngle(WORLD_UP, i);
//    children[1].scale.splat(sin(i));
    
    children.forEach((e) {
      e.rotation.setEuler(i, i, i);
    });
  }
  
  render() {
    super.render();
    _stats.end();
  }
}
