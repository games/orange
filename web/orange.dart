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

    
    var sphere = new Sphere(1.0, 16, 16);
    sphere.position.setValues(1.0, 0.0, 0.0);
    add(sphere);
    
    var ambientLight = new Light(0x95C7DE, Light.AMBIENT);
    lights.add(ambientLight);
    
    var directLight = new Light(0xcdffff, Light.DIRECT);
    directLight.position = new Vector3(0.85, 0.8, 0.75);
    directLight.ambientIntensity = new Vector3(0.03, 0.03, 0.03);
    directLight.diffuseIntensity = new Vector3(1.0, 1.0, 1.0);
    directLight.specularIntensity = new Vector3(1.0, 1.0, 1.0);
    lights.add(directLight);
  }
  
  var i = 0.0;
  update(double interval) {
    _stats.begin();
    
    var moveTarget = lights[1];
    
    if(director.keyboard.held(KeyCode.LEFT)){
      moveTarget.position += new Vector3(-0.1, 0.0, 0.0);
//      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians + 0.01);
    }else if(director.keyboard.held(KeyCode.RIGHT)){
      moveTarget.position += new Vector3(0.1, 0.0, 0.0);
//      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians - 0.01);
    }else if(director.keyboard.held(KeyCode.UP)){
//      camera.position += camera.frontDirection * 0.1;
      moveTarget.position += new Vector3(0.0, 0.1, 0.0);
    }else if(director.keyboard.held(KeyCode.DOWN)){
//      camera.position -= camera.frontDirection * 0.1;
      moveTarget.position += new Vector3(0.0, -0.1, 0.0);
    }
    
      var s = interval / 1000.0;
      i += 0.02 ;
//      lights[1].position += new Vector3(cos(i), 1.0, sin(i));
//      print(new Vector3(cos(i), 0.0, sin(i)));
//      camera.lookAt(children[0].position);
//    children[0].rotation.setAxisAngle(WORLD_UP, i);
//    children[1].scale.splat(sin(i));
    
    children.forEach((e) {
//      e.rotation.setEuler(i, i, i);
    });
  }
  
  render() {
    super.render();
    _stats.end();
  }
}



class TestLoadMesh extends Scene {
  Stats _stats;
  
  enter() {
    _stats = new Stats();
    document.body.append(_stats.container);
    HttpRequest.getString("hum_f.json").then(addMesh);
  }
  
  addMesh(String responseData) {
    var mesh = parseMesh(responseData);
    mesh.position = new Vector3(-2.0 + children.length * 5, 0.0, 0.0);
    add(mesh);
  }
  
  update(double interval) {
    _stats.begin();
    
    var moveTarget = camera;
    
    if(director.keyboard.held(KeyCode.LEFT)){
      moveTarget.position += new Vector3(-0.1, 0.0, 0.0);
//      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians + 0.01);
    }else if(director.keyboard.held(KeyCode.RIGHT)){
      moveTarget.position += new Vector3(0.1, 0.0, 0.0);
//      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians - 0.01);
    }else if(director.keyboard.held(KeyCode.UP)){
//      camera.position += camera.frontDirection * 0.1;
      moveTarget.position += new Vector3(0.0, 0.0, 0.1);
    }else if(director.keyboard.held(KeyCode.DOWN)){
//      camera.position -= camera.frontDirection * 0.1;
      moveTarget.position += new Vector3(0.0, 0.0, -0.1);
    }
    
  }
  
  render() {
    super.render();
    _stats.end();
  }
  
  
}
















