import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'dart:html';
import 'package:vector_math/vector_math.dart';
import 'dart:math';

class TestLightingScene extends Scene {

  Stats _stats;
  Mesh _cube;
  Light _directionalLight;
  Light _pointLight;
  Light _spotLight;
  
  enter() {
    _stats = new Stats();
    document.body.append(_stats.container);
    

    camera = new PerspectiveCamera();
    camera.position.y = 5.0;
    camera.position.z = 10.0;
    camera.lookAt(new Vector3(0.0, 0.0, 0.0));
    
    _cube = new Cube(0.5, 0.5, 0.5);
    _cube.material.shader = Shader.simpleShader;
    _cube.material.color = new Color.fromHex(0xff0000);
    _cube.position.setValues(-3.0, 1.0, 0.0);
    _cube.computeVertexNormals();
    add(_cube);
    
    var flooter = new Plane(10.0, 10.0);
    flooter.material.color = new Color.fromHex(0xffffff);
    add(flooter);
    
    var cube = new Cube(2.0, 2.0, 2.0);
    cube.material.shader = Shader.simpleShader;
    cube.material.color = new Color.fromHex(0xff0000);
    cube.position.setValues(-2.0, 1.0, 0.0);
//    cube.rotation.setAxisAngle(WORLD_UP, -0.2);
    cube.computeVertexNormals();
    add(cube);

    var light0 = new Light.fromColor(new Color(51, 51, 51), Light.AMBIENT);
    light0.intensity = 1.0;
    lights.add(light0);
    
    _directionalLight = new Light(0xffffff, Light.DIRECT);
    _directionalLight.position = new Vector3(0.0, 10.0, 0.0);
    _directionalLight.rotation.setEuler(0.0, 0.0, 0.0);
    _directionalLight.updateMatrix();
//    lights.add(_directionalLight);
    
    _pointLight = new Light(0xffffff, Light.POINT);
    _pointLight.position = new Vector3(0.0, 3.0, 0.0);
    _pointLight.intensity = 1.0;
    lights.add(_pointLight);
    
    _spotLight = new Light(0xcdffff, Light.SPOTLIGHT);
    _spotLight.position = new Vector3(0.0, 5.0, 2.0);
    _spotLight.intensity = 1.0;
    _spotLight.angle = PI;
    _spotLight.angleFalloff = 0.15;
//    lights.add(_spotLight);
    
    
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

    i += 0.01;
    i = i % (PI * 2);
    
//    _directionalLight.rotation.setAxisAngle(WORLD_UP, i);
//    _directionalLight.updateMatrix();
    
//    _cube.rotation.setAxisAngle(WORLD_UP, i);
    
//    _pointLight.position.setValues(cos(i) * 5, 3.0, sin(i) * 5);
//    _pointLight.position.setValues(0.0, cos(i) * 5, 0.0);
    _cube.position = _pointLight.position.clone();
    
//      _spotLight.angle = 0.8624042272433387;//sin(i);
//      _spotLight.angle = sin(i);
//      print(_spotLight.angle);
//      _spotLight.angleFalloff = 0.05;
//      _visual.position = _spotLight.position.clone();
  }
  
  render() {
    super.render();
    _stats.end();
  }
}