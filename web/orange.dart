import 'dart:html';
import 'dart:math';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'package:vector_math/vector_math.dart';

void main() {

  initOrange(query('#container'));
  
  var scene = new TestScene();
//  var scene = new TestLoadMesh();
  
  scene.camera = new PerspectiveCamera();
  scene.camera.position.y = 5.0;
  scene.camera.position.z = 10.0;
  scene.camera.lookAt(new Vector3(0.0, 0.0, 0.0));
  
  director.replace(scene);
  director.run();
  
}

class TestScene extends Scene {

  Stats _stats;
  Mesh _visual;
  Light _spotLight;
  
  enter() {
    _stats = new Stats();
    document.body.append(_stats.container);
    
    var cube = new Cube(2.0, 2.0, 2.0);
    cube.material.shader = Shader.simpleShader;
    cube.material.color = new Color.fromHex(0x00ff00);
    cube.position.setValues(-3.0, 1.0, 0.0);
    cube.computeVertexNormals();
    add(cube);
    
//    var cube2 = new Cube(1.0, 1.0, 1.0);
//    cube2.material.shader = Shader.phongShader;
//    cube2.material.color = new Color.fromHex(0xffff00);
//    cube2.position.setValues(2.0, 3.0, 0.0);
//    cube2.computeFaceNormals();
//    add(cube2);

    
//    var sphere = new Sphere(1.0, 8, 8);
//    sphere.position.setValues(-3.0, 1.0, 0.0);
//    sphere.wireframe = false;
//    sphere.material.shader = Shader.simpleShader;
//    sphere.computeVertexNormals();
//    add(sphere);
    
//    var sphere2 = new Sphere(1.0, 8, 8);
//    sphere2.position.setValues(3.0, 1.0, 0.0);
////    sphere2.wireframe = true;
//    sphere2.material.shader = Shader.phongShader;
//    sphere2.computeFaceNormals();
//    add(sphere2);
    
    var flooter = new Plane(10.0, 10.0);
//    flooter.material.shader = Shader.phongShader;
    add(flooter);

    var light0 = new Light(0x333333, Light.AMBIENT);
    lights.add(light0);
    
//    var light1 = new Light(0xcdffff, Light.DIRECT);
//    light1.position = new Vector3(1.0, 1.0, 0.0);
//    lights.add(light1);
    
    _spotLight = new Light(0xcdffff, Light.SPOTLIGHT);
    _spotLight.position = new Vector3(0.0, 10.0, 0.0);
    _spotLight.intensity = 1.0;
    _spotLight.angle = PI;
    _spotLight.angleFalloff = 0.15;
    lights.add(_spotLight);
    
    _visual = new Cube(0.5, 0.5, 0.5);
    _visual.position = _spotLight.position.clone();
    add(_visual);
    
    HttpRequest.getString("teapot.json").then(addMesh);
  }
  
  addMesh(String responseData) {
    var mesh = parseMesh(responseData);
    mesh.position = new Vector3(3.0, 0.0, 0.0);
    mesh.material = new Material();
    mesh.material.shader = Shader.simpleShader;
    mesh.computeVertexNormals();
    add(mesh);
  }
  
  var i = 0.0;
  update(double interval) {
    _stats.begin();
    
    var moveTarget = lights[0];
    
    if(director.keyboard.held(KeyCode.LEFT)){
//      moveTarget.position += new Vector3(-0.1, 0.0, 0.0);
//      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians + 0.01);
      camera.position += WORLD_LEFT * 0.1;
      camera.lookAt(new Vector3(0.0, 0.0, 0.0));
    }else if(director.keyboard.held(KeyCode.RIGHT)){
//      moveTarget.position += new Vector3(0.1, 0.0, 0.0);
//      camera.rotation.setAxisAngle(WORLD_UP, camera.rotation.radians - 0.01);
      camera.position += WORLD_RIGHT * 0.1;
      camera.lookAt(new Vector3(0.0, 0.0, 0.0));
    }else if(director.keyboard.held(KeyCode.UP)){
//      camera.position += camera.frontDirection * 0.1;
//      moveTarget.position += new Vector3(0.0, 0.1, 0.0);
      camera.position += WORLD_UP * 0.1;
      camera.lookAt(new Vector3(0.0, 0.0, 0.0));
    }else if(director.keyboard.held(KeyCode.DOWN)){
      camera.position -= WORLD_UP * 0.1;
      camera.lookAt(new Vector3(0.0, 0.0, 0.0));
//      moveTarget.position += new Vector3(0.0, -0.1, 0.0);
    }
    
      var s = interval / 1000.0;
      i += 0.02 ;
//      lights[1].position += new Vector3(cos(i), 1.0, sin(i));
//      print(new Vector3(cos(i), 0.0, sin(i)));
//      camera.lookAt(children[0].position);
//    children[0].rotation.setAxisAngle(WORLD_UP, i);
//    children[1].scale.splat(sin(i));
    
//    children.forEach((e) {
//      e.rotation.setAxisAngle(WORLD_UP, i % (2*PI));
//    });
      
//      lights[1].position.setValues(lights[1].position.x, cos(i) * 10, 0.0);
      _spotLight.angle = sin(i);
      _spotLight.angleFalloff = 0.5;
      _visual.position = _spotLight.position.clone();
  }
  
  render() {
    super.render();
    _stats.end();
  }
}



class TestLoadMesh extends Scene {
  Stats _stats;
  Mesh _visual;
  
  enter() {
    _stats = new Stats();
    document.body.append(_stats.container);

    _visual = new Cube(1.0, 1.0, 1.0);
    _visual.position.setValues(1.0, 1.0, 1.0);
    add(_visual);
    
//    HttpRequest.getString("npc_huf_town_01.json").then(addMesh);
    HttpRequest.getString("hum_f.json").then(addMesh);
    HttpRequest.getString("teapot.json").then(addMesh);
//    HttpRequest.getString("greatsword21.json").then(addMesh);
    
    
    var ambientLight = new Light(0xff0000, Light.AMBIENT);
//    lights.add(ambientLight);
    
    var directLight = new Light(0xffffff, Light.DIRECT);
    directLight.position = new Vector3(1.0, 0.0, 0.0);
//    lights.add(directLight);
    
    var pointLight = new Light(0xffffff, Light.POINT);
    pointLight.position = new Vector3(0.0, 3.0, 0.0);
    lights.add(pointLight);
  }
  
  int count = 0;
  addMesh(String responseData) {
    var mesh = parseMesh(responseData);
    mesh.position = new Vector3(-2.0 + (count++) * 5, 0.0, 0.0);
//    mesh.position = new Vector3(0.0, 0.0, 0.0);
    mesh.material = new Material();
    mesh.material.shader = Shader.simpleShader;
    mesh.computeVertexNormals();
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
//      moveTarget.position += new Vector3(0.0, 0.0, 0.1);
      camera.position += WORLD_UP * 0.1;
      camera.lookAt(new Vector3(0.0, 0.0, 0.0));
    }else if(director.keyboard.held(KeyCode.DOWN)){
//      camera.position -= camera.frontDirection * 0.1;
      moveTarget.position += new Vector3(0.0, 0.0, -0.1);
    }
    
    
    var s = interval / 1000.0;
    i += 0.02 ;
//    children.forEach((e) {
//      e.rotation.setAxisAngle(WORLD_UP, i % (2 * PI));
//    });
//    var r = 5.0;
//    lights[0].position.setValues(cos(i) * r, 1.0, sin(i) * r);
//    children[0].position.setValues(cos(i) * r, 1.0, sin(i) * r);
    
    _visual.position = lights[0].position.clone();
  }
  
  render() {
    super.render();
    _stats.end();
  }
  
  
}
















