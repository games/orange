import 'dart:html';
import 'dart:math';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'package:vector_math/vector_math.dart';
import 'test_lighting.dart';

void main() {

  initOrange(query('#container'));
  
  var scene = new TestLightingScene();
//  var scene = new TestLoadMesh();
  
  scene.camera = new PerspectiveCamera();
  scene.camera.position.y = 5.0;
  scene.camera.position.z = 10.0;
  scene.camera.lookAt(new Vector3(0.0, 0.0, 0.0));
  
  director.replace(scene);
  director.run();
  
}





class TestLoadMesh extends Scene {
  Stats _stats;
  Mesh _visual;
  
  enter() {
    _stats = new Stats();
    document.body.append(_stats.container);

    _visual = new Cube(1.0, 1.0, 1.0);
    _visual.position.setValues(1.0, 1.0, 1.0);
//    add(_visual);
    
//    HttpRequest.getString("npc_huf_town_01.json").then(addMesh);
//    HttpRequest.getString("hum_f.json").then(addMesh);
//    HttpRequest.getString("teapot.json").then(addMesh);
//    HttpRequest.getString("greatsword21.json").then(addMesh);
    HttpRequest.getString("mm.json").then(addMesh);
    
    
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
    mesh.scale.setValues(0.1, 0.1, 0.1);
    mesh.material = new Material();
    mesh.material.shader = Shader.simpleShader;
//    mesh.wireframe = true;
//    mesh.computeVertexNormals();
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
















