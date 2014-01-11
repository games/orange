import 'dart:html' as html;
import '../lib/orange.dart';
//import 'package:stats/stats.dart';
import 'dart:async';
//import 'package:vector_math/vector_math.dart';


double _lastElapsed = 0.0;
Renderer renderer;
Node node;
Animation animation;

void main() {
  html.window.onResize.listen((e){
    renderer.resize();
  });
  
  renderGltf();
//  renderWgl();
}

renderGltf() {
  var canvas = html.querySelector("#container");
  renderer = new Renderer(canvas);
  renderer.camera.center = new Vector3(0.0, -1.0, -500.0);
  var url = "http://127.0.0.1:3030/orange/models/duck/duck.json";
//  url = "http://127.0.0.1:3030/orange/models/astroboy/astroboy.json";
  var loader = new GltfLoader();
  loader.load(renderer.ctx, url).then((m) {
    node = m;
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
  var loader = new WglLoader();
  loader.load(renderer.ctx, url).then((m) {
    node = m;
    animation = new Animation();
    animation.load("http://127.0.0.1:3030/orange/models/model/run_forward").then((_) {
      var frameId = 0;
      var frameTime = 1000 ~/ animation.frameRate;
      new Timer.periodic(new Duration(milliseconds: frameTime), (t) {
        animation.evaluate(frameId % animation.frameCount, node);
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
  renderer.draw(node);

  _lastElapsed = elapsed;
}


















