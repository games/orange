import 'dart:html' as html;
import '../lib/orange.dart';
//import 'package:stats/stats.dart';
import 'dart:async';
//import 'package:vector_math/vector_math.dart';


double _lastElapsed = 0.0;
Renderer renderer;
Pass pass;
List<Mesh> meshes = [];
Animation animation;

void main() {
  html.window.onResize.listen((e){
    renderer.resize();
  });
  
  
//  renderGltf();
//  renderWgl();
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





renderGltf() {
  var canvas = html.querySelector("#container");
  renderer = new Renderer(canvas);
  renderer.camera.center = new Vector3(0.0, -1.0, -10.0);
  pass = new Pass();
  pass.shader = new Shader(renderer.ctx, skinnedModelVS, skinnedModelFS);
  
  var url = "http://127.0.0.1:3030/orange/models/duck/duck.json";
  url = "http://127.0.0.1:3030/orange/models/astroboy/astroboy.json";
//  url = "http://127.0.0.1:3030/orange/models/abaddon/abaddon.json";
//  url = "http://127.0.0.1:3030/orange/models/mirana/mirana.json";
//  url = "http://127.0.0.1:3030/orange/models/pudge/pudge.json";
  
  var loader = new GltfLoader();
  loader.load(renderer.ctx, url).then((m) {
    meshes.add(m);
    html.window.requestAnimationFrame(_animate);
  });
}

renderWgl() {
  var url = "http://127.0.0.1:3030/orange/models/model/main_player_lorez";
//  url = "http://127.0.0.1:3030/orange/models/model/main_weapon001";
//  url = "http://127.0.0.1:3030/orange/models/model/barrelSmall";
//  url = "http://127.0.0.1:3030/orange/models/model/crateMedium";
//  url = "http://127.0.0.1:3030/orange/models/model/vat";
  var canvas = html.querySelector("#container");
  renderer = new Renderer(canvas, true);
  renderer.camera.center = new Vector3(0.0, -0.5, 0.0);
  pass = new Pass();
  pass.shader = new Shader(renderer.ctx, skinnedModelVS2, skinnedModelFS2);
  
  var loader = new WglLoader();
  loader.load(renderer.ctx, url).then((m) {
    meshes.add(m);
    animation = new Animation();
    animation.load("http://127.0.0.1:3030/orange/models/model/run_forward").then((_) {
      var frameId = 0;
      var frameTime = 1000 ~/ animation.frameRate;
      new Timer.periodic(new Duration(milliseconds: frameTime), (t) {
        animation.evaluate(frameId % animation.frameCount, meshes.first);
        frameId++;
      });
    });
    html.window.requestAnimationFrame(_animate);
  });
}


_animate(num elapsed) {
  html.window.requestAnimationFrame(_animate);
  var interval = elapsed - _lastElapsed;
  
  renderer.camera.update(interval);
  renderer.prepare();
  meshes.forEach((m) => renderer.draw(m));

  _lastElapsed = elapsed;
}


















