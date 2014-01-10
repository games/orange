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
  var url = "http://127.0.0.1:3030/orange/testmodel/model/main_player_lorez";
//  url = "http://127.0.0.1:3030/orange/testmodel/model/main_weapon001";
//  url = "http://127.0.0.1:3030/orange/testmodel/model/barrelSmall";
//  url = "http://127.0.0.1:3030/orange/testmodel/model/crateMedium";
//  url = "http://127.0.0.1:3030/orange/testmodel/model/vat";
  
  var canvas = html.querySelector("#container");
  renderer = new Renderer(canvas);
  
  var loader = new WglLoader();
  loader.load(renderer.ctx, url).then((m) {
    node = m;
    
    animation = new Animation();
    animation.load("http://127.0.0.1:3030/orange/testmodel/model/run_forward").then((_) {
      var frameId = 0;
      var frameTime = 1000 ~/ animation.frameRate;
      new Timer.periodic(new Duration(milliseconds: frameTime), (t) {
        animation.evaluate(frameId % animation.frameCount, node);
        frameId++;
      });
    });
    
    html.window.requestAnimationFrame(_animate);
  });
  
  html.window.onResize.listen((e){
    renderer.resize();
  });
}

_animate(num elapsed) {
  html.window.requestAnimationFrame(_animate);
  var interval = elapsed - _lastElapsed;
  
  renderer.camera.update(interval);
  renderer.draw(node);

  _lastElapsed = elapsed;
}


















