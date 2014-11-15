library orange_examples;

import 'dart:html' as Html;
import 'dart:math';
import 'dart:async';
import 'dart:web_gl' as gl;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';



void main() {
  var canvas = Html.querySelector("#container");
  
  var orange = new Orange(canvas);
  
  orange.initialize = () {
    new OBJLoader().load("models/obj/head.obj").then((mesh) {
      orange.root.addChild(new Node("head")
      ..addComponent(new MeshFilter(mesh))
      ..addComponent(new MeshRenderer()..materials = [Material.defaultMaterial()]));
    });
    
    orange.mainCamera.transform.translate(0.0, 1.0, 5.0);
  };
  
  orange.enterFrame = (GameTime gameTime) {
    var head = orange.root.findChild("head");
    if(head != null)
      head.transform.rotateY(gameTime.elapsed / 1000.0);
  };
  
  orange.exitFrame = () {
    
  };
  
  orange.run();
  
}









