import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:async';
//import 'package:vector_math/vector_math.dart';


double _lastElapsed = 0.0;
Renderer renderer;
Pass pass;
List<Mesh> meshes = [];
Animation animation;
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
  renderer.camera.center = new Vector3(0.0, -1.5, -3.0);
  var url = "http://127.0.0.1:3030/orange/models/ogre/alric.json";
  var loader = new OgreLoader();
  loader.load(renderer.ctx, url).then((m) {
    m.position.setValues(-2.0, 0.0, 0.0);
    meshes.add(m);
    html.window.requestAnimationFrame(_animate);
  });
  
  loader = new OgreLoader();
  loader.load(renderer.ctx, "http://127.0.0.1:3030/orange/models/ogre/boss_sturm.json").then((m) {
    m.position.setValues(2.0, 0.0, 0.0);
    meshes.add(m);
  });
  
}


_animate(num elapsed) {
  var interval = elapsed - _lastElapsed;
  stats.begin();
  
  renderer.camera.update(interval);
  renderer.prepare();
  meshes.forEach((m) => renderer.draw(m));

  stats.end();
  _lastElapsed = elapsed;
  html.window.requestAnimationFrame(_animate);
}


















