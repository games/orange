import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:async';
//import 'package:vector_math/vector_math.dart';


double _lastElapsed = 0.0;
Renderer renderer;
Pass pass;
List<Mesh> meshes = [];
Stats stats;

void main() {
  stats = new Stats();
  html.document.body.children.add(stats.container);
  html.window.onResize.listen((e){
    renderer.resize();
  });
  
  renderOgre();
}

renderOgre() {
  var canvas = html.querySelector("#container");
  renderer = new Renderer(canvas);
  renderer.camera.center = new Vector3(0.0, -1.0, 0.0);
  
  var light1 = new Light(0xff0000, Light.SPOTLIGHT);
  renderer.lights.add(light1);
  
  var url = "http://127.0.0.1:3030/orange/models/ogre/alric.orange";
  var loader = new OgreLoader();
  loader.load(renderer.ctx, url).then((m) {
    m.position.setValues(0.0, 0.0, 0.0);
    m.animator.switchAnimation("Die");
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


















