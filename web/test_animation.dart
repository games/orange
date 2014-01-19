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
  
  run() {
    stats = new Stats();
    html.document.body.children.add(stats.container);
    
    var canvas = html.querySelector("#container");
    renderer = new Renderer(canvas);
    renderer.camera.center = new Vector3(0.0, -1.0, 0.0);
    renderer.pass = new Pass();
    renderer.pass.shader = new Shader(renderer.ctx, skinnedModelVS, skinnedModelFS);
    
    var light0 = new Light.fromColor(new Color(51, 51, 51), Light.AMBIENT);
    light0.intensity = 1.0;
    renderer.lights.add(light0);
    
    light0 = new Light(0xffffff, Light.DIRECT);
    light0.rotation.rotateX(math.PI / 4);//    .setEuler(0.0, PI / 4, 0.0);
    light0.intensity = 1.0;
    renderer.lights.add(light0);

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
//      m.rotation.rotateY(interval / 1000);
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























