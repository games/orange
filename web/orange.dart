import 'dart:html';
import 'dart:math';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'package:vector_math/vector_math.dart';

void main() {

  initOrange(query('#container'));
  
//  var scene = new TestScene();
  var scene = new TestLoadMesh();
  
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
    cube.position.setValues(-2.0, 0.0, 0.0);
    add(cube);

    
    var sphere = new Sphere(1.0, 16, 16);
    sphere.position.setValues(2.0, 0.0, 0.0);
    sphere.wireframe = false;
    add(sphere);
    
//    var ambientLight = new Light(0x95C7DE, Light.AMBIENT);
//    lights.add(ambientLight);
    
    var directLight = new Light(0xcdffff, Light.DIRECT);
    directLight.position = new Vector3(1.0,1.0,1.0);
    directLight.ambient = new Vector3(0.0, 0.0, 1.0);
    directLight.diffuse = new Vector3(1.0, 0.0, 0.0);
    directLight.specular = new Vector3(0.0, 1.0, 0.0);
    directLight.shininess = 100.0;
    lights.add(directLight);
  }
  
  var i = 0.0;
  update(double interval) {
    _stats.begin();
    
    var moveTarget = lights[0];
    
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
      e.rotation.setEuler(i, i, i);
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
//    HttpRequest.getString("npc_huf_town_01.json").then(addMesh);
    HttpRequest.getString("hum_f.json").then(addMesh);
//    HttpRequest.getString("greatsword21.json").then(addMesh);
    
    var cube = new Cube(1.0, 1.0, 1.0);
    cube.position.setValues(-2.0, 0.0, 0.0);
//    add(cube);
    
    var ambientLight = new Light(0xff0000, Light.AMBIENT);
    lights.add(ambientLight);
    
    var directLight = new Light(0xffffff, Light.DIRECT);
    directLight.position = new Vector3(1.0,1.0,1.0);
    directLight.ambient = new Vector3(0.0, 0.0, 0.0);
    directLight.diffuse = new Vector3(0.0, 0.0, 0.0);
    directLight.specular = new Vector3(1.0, 1.0, 1.0);
    directLight.shininess = 100.0;
    lights.add(directLight);
  }
  
  addMesh(String responseData) {
    var mesh = parseMesh(responseData);
//    mesh.position = new Vector3(-2.0 + children.length * 5, -1.0, 0.0);
    mesh.position = new Vector3(0.0, -1.0, 5.0);
    add(mesh);
  }
  
  var i = 0.0;
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
    
    
    var s = interval / 1000.0;
    i += 0.02 ;
    children.forEach((e) {
      e.rotation.setAxisAngle(WORLD_UP, sin(i));
    });
  }
  
  render() {
    super.render();
    _stats.end();
  }
  
  
}
















