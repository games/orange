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
  };
  
  orange.enterFrame = (GameTime gameTime) {
    
  };
  
  orange.exitFrame = () {
    
  };
  
  orange.run();
  
}









