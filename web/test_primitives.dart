import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'dart:typed_data';


class TestPrimitives {
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
//    renderer.camera.center = new Vector3(0.0, -1.0, 0.0);
    renderer.camera.position = new Vector3(0.0, 0.0, 5.0);
    renderer.pass = new Pass();
    renderer.pass.shader = new Shader(renderer.ctx, lightingModelVS, lightingModelFS);
//    renderer.pass.shader = new Shader(renderer.ctx, simpleModelVS, simpleModelFS);
    
    var cube = new Cube();
    cube.position.setValues(-1.0, 0.0, 0.0);
    cube.material = new Material();
    cube.material.shininess = 64.0;
    cube.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cube.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cube.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
//    meshes.add(cube);
    
    var sphere = new Sphere();
    sphere.position.setValues(0.0, 0.0, 0.0);
    sphere.material = new Material();
    sphere.material.shininess = 64.0;
    sphere.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
//    meshes.add(sphere);
    
    var cone = new Cone(bottomRadius: 0.2, height: 0.5);
    cone.position.setValues(0.0, 0.0, 0.0);
    cone.material = new Material();
    cone.material.shininess = 64.0;
    cone.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cone.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cone.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
//    meshes.add(cone);
    
    var plane = new Plane();
    plane.rotation.rotateX(-PI / 2);
    plane.position.setValues(0.0, -0.5, 0.0);
    plane.material = new Material();
    plane.material.shininess = 64.0;
    plane.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    plane.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
//    meshes.add(plane);
    
    var coordinate = new Coordinate();
    meshes.add(coordinate);
    
    _directionalLight = new Light(0xffffff, Light.DIRECT);
    _directionalLight.rotation.rotateX(-PI);
    _directionalLight.intensity = 1.0;
    renderer.lights.add(_directionalLight);
    
    _pointLight = new Light(0xffffff, Light.POINT);
    _pointLight.position = new Vector3(5.0, 5.0, 5.0);
    _pointLight.intensity = 2.0;
    renderer.lights.add(_pointLight);
    
//    _spotLight = new Light(0xff0000, Light.SPOTLIGHT);
//    _spotLight.position = new Vector3(0.0, 5.0, 0.0);
//    _spotLight.intensity = 2.0;
//    _spotLight.direction = new Vector3(0.0, -1.0, 0.0);
//    _spotLight.spotCutoff = PI / 2;
//    _spotLight.spotExponent = 10.0;
//    _spotLight.constantAttenuation = 0.05;
//    _spotLight.linearAttenuation = 0.05;
//    _spotLight.quadraticAttenuation = 0.01;
//    renderer.lights.add(_spotLight);
    
    html.window.requestAnimationFrame(_animate);
  }


  _animate(num elapsed) {
    var interval = elapsed - _lastElapsed;
    stats.begin();
    
//    meshes.forEach((m){
//      m.rotation.rotateX(interval / 1000);
//      m.rotation.rotateY(interval / 1000);
//    });
    
    renderer.camera.update(interval);
    renderer.camera.updateMatrix();
    renderer.prepare();
    meshes.forEach((m) => renderer.draw(m));

    stats.end();
    _lastElapsed = elapsed;
    html.window.requestAnimationFrame(_animate);
  }
}























