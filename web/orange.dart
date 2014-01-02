import 'dart:html';
import 'dart:math';
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
//import 'package:vector_math/vector_math.dart';

void main() {

  var url = "http://127.0.0.1:3030/orange/web/duck/duck.json";
  var canvas = querySelector("#container");
  var director = new Director(canvas);
  
  var loader = new Loader(url);
  loader.start().then((scene) {
    
//    scene.camera = new PerspectiveCamera(canvas.width / canvas.height);
//    scene.camera.translate(new Vector3(0.0, 2.0, 500.0));
//    scene.camera.lookAt(new Vector3(0.0, 0.0, -1.0));
    
    scene.camera.aspect = canvas.width / canvas.height;
    scene.camera.updateProjection();
    
    director.replace(scene);
    director.startup();
    
  });
}



















