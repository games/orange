import 'dart:html';
import 'dart:math';
import '../lib/orange.dart';
import 'package:stats/stats.dart';
//import 'package:vector_math/vector_math.dart';

void main() {

  var url = "http://127.0.0.1:3030/orange/web/abaddon/abaddon.json";
  url = "http://127.0.0.1:3030/orange/web/astroboy/astroboy.json";
  var canvas = querySelector("#container");
  var director = new Director(canvas);
  var scene = new Scene();
  
  var loader = new Loader(url);
  loader.start().then((data) {
    var root = data["root"];
    var resources = data["resources"];
    
    scene.resources = resources;
    scene.nodes.add(root);
    
    scene.camera = new PerspectiveCamera(canvas.width / canvas.height);
    scene.camera.translate(new Vector3(0.0,2.0, 15.0));
//    scene.camera.lookAt(new Vector3(0.0, 0.0, -1.0));
    
    root.rotateX(radians(-90.0));
//    root.rotateZ(radians(-35.0));
    
    director.replace(scene);
    director.startup();
    
  });
}



















