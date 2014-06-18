import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';


class TestPrimitives {
  double _lastElapsed = 0.0;
  RendererOld renderer;
  Pass pass;
  List<Mesh> meshes = [];
  Stats stats;

  Light _directionalLight;
  Light _pointLight;
  
  
  run() {
    stats = new Stats();
    html.document.body.children.add(stats.container);
    
    var canvas = html.querySelector("#container");
    renderer = new RendererOld(canvas);
//    renderer.camera.center = new Vector3(0.0, -1.0, 0.0);
    renderer.camera.position = new Vector3(0.0, 0.0, 5.0);
    renderer.camera.lookAt(new Vector3.zero());
    renderer.pass = new Pass();
    renderer.pass.shader = new Shader(renderer.ctx, lightingModelVS, lightingModelFS);
//    renderer.pass.shader = new Shader(renderer.ctx, simpleModelVS, simpleModelFS);
    
    var cube = new Cube(width: 1, height: 0.5, depth: 1.5);
    cube.position.setValues(-1.0, 0.0, 0.0);
    cube.material = new Material();
    cube.material.shininess = 64.0;
    cube.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cube.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cube.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(cube);
    
    var sphere = new Sphere(widthSegments: 32, heightSegments: 32);
    sphere.position.setValues(1.5, 0.0, 0.0);
    sphere.material = new Material();
    sphere.material.shininess = 64.0;
    sphere.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(sphere);
    
    var cone = new Cone(bottomRadius: 0.2, height: 0.5);
    cone.position.setValues(0.0, 0.0, 0.0);
    cone.material = new Material();
    cone.material.shininess = 64.0;
    cone.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cone.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cone.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(cone);
    
    var plane = new Plane(width: 2, height: 2);
    plane.rotation.rotateX(-PI / 2);
    plane.position.setValues(0.0, -0.5, 0.0);
    plane.material = new Material();
    plane.material.shininess = 64.0;
    plane.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    plane.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(plane);
    
    var coordinate = new Coordinate();
    coordinate.position.setValues(-2.5, 1.5, 0.0);
    meshes.add(coordinate);
    
    _directionalLight = new DirectionalLight(0xffffff);
    _directionalLight.rotation.rotateX(-PI);
    _directionalLight.intensity = 1.0;
//    renderer.lights.add(_directionalLight);
    
    _pointLight = new PointLight(0xffffff);
    _pointLight.position = new Vector3(5.0, 5.0, 5.0);
    _pointLight.intensity = 2.0;
    renderer.lights.add(_pointLight);
    
    html.window.requestAnimationFrame(_animate);
  }


  _animate(num elapsed) {
    var interval = elapsed - _lastElapsed;
    stats.begin();
    
//    meshes.forEach((m){
//      m.rotation.rotateX(interval / 500);
//      m.rotation.rotateY(interval / 1000);
//      m.rotation.rotateZ(interval / 800);
//    });
    
//    renderer.camera.update(interval);
//    renderer.camera.position.setValues(cos(elapsed / 1000) * 5, 1.0, sin(elapsed / 1000) * 5);
//    renderer.camera.lookAt(new Vector3.zero());
//    renderer.camera.updateMatrix();
    
    _pointLight.position.setValues(cos(elapsed / 1000) * 5, 2.0, sin(elapsed / 1000) * 5);
    
    renderer.camera.update(interval);
    renderer.camera.updateMatrix();
    renderer.prepare();
    meshes.forEach((m) => renderer.draw(m));

    stats.end();
    _lastElapsed = elapsed;
    html.window.requestAnimationFrame(_animate);
  }
}























