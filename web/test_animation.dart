import 'dart:html' as html;
import 'dart:math' as math;
import '../lib/orange.dart';
import 'package:stats/stats.dart';


class TestAnimation {
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
    renderer.camera.center = new Vector3(0.0, -1.0, 0.0);
    
    var light0 = new Light.fromColor(new Color(51, 51, 51), Light.AMBIENT);
    light0.intensity = 1.0;
    renderer.lights.add(light0);
    
    _directionalLight = new Light(0xffffff, Light.DIRECT);
    _directionalLight.rotation.rotateX(math.PI / 4);//    .setEuler(0.0, PI / 4, 0.0);
    _directionalLight.updateMatrix();
    _directionalLight.intensity = 1.0;
//  renderer.lights.add(_directionalLight);
    
    _pointLight = new Light(0xffffff, Light.POINT);
    _pointLight.position = new Vector3(1.0, 0.1, 0.0);
    _pointLight.intensity = 0.2;
    renderer.lights.add(_pointLight);
    
//  _spotLight = new Light(0xff0000, Light.SPOTLIGHT);
//  _spotLight.position = new Vector3(1.0, 1.0, 0.0);
//  _spotLight.intensity = 1.0;
//  _spotLight.direction = new Vector3(1.0, 0.0, 0.0);
//  _spotLight.spotCutoff = math.PI / 2;
//  _spotLight.spotExponent = 10.0;
//  _spotLight.constantAttenuation = 0.05;
//  _spotLight.linearAttenuation = 0.05;
//  _spotLight.quadraticAttenuation = 0.01;
//  renderer.lights.add(_spotLight);
    
    var url = "http://127.0.0.1:3030/orange/models/ogre/alric.orange";
    var loader = new OgreLoader();
    loader.load(renderer.ctx, url).then((m) {
      m.position.setValues(0.0, 0.0, 0.0);
      m.animator.switchAnimation("Idle");
      meshes.add(m);
      html.window.requestAnimationFrame(_animate);
    });
  }


  _animate(num elapsed) {
    var interval = elapsed - _lastElapsed;
    stats.begin();
    
    meshes.forEach((m){
      if(m.animator != null) 
        m.animator.evaluate(interval); 
    });
    
    renderer.camera.update(interval);
    renderer.prepare();
    meshes.forEach((m) => renderer.draw(m));

    stats.end();
    _lastElapsed = elapsed;
    html.window.requestAnimationFrame(_animate);
  }
}























