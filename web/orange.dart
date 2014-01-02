import 'dart:html';
import 'dart:math';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
//import 'package:vector_math/vector_math.dart';

void main() {

  var url = "http://127.0.0.1:3030/orange/web/abaddon/abaddon.json";
  var canvas = querySelector("#container");
  var director = new Director(canvas);
  
  var loader = new Loader(url);
  loader.start().then((scene) {
    
//    scene.camera = new PerspectiveCamera(canvas.width / canvas.height);
    
    scene.camera = new PerspectiveCamera(canvas.width / canvas.height);
    scene.camera.translate(new Vector3(0.0, 0.0, 700.0));
    scene.nodes.forEach((n) {
        n.rotateX(radians(-70.0));
        n.rotateZ(radians(-35.0));
    });
    
    director.replace(scene);
    director.startup();
    
  });
}



















