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
    var material = Material.defaultMaterial();
    material.mainTexture = orange.resources.loadTexture("textures/firefox.png");
    material.wireframe = false;

    var material2 = Material.defaultMaterial();
    material2.mainTexture = orange.resources.loadTexture("textures/mosaic.jpg");
    material2.wireframe = true;

    var material3 = Material.texturedMaterial();
    material3.mainTexture = orange.resources.loadTexture("textures/wood.jpg");

    new OBJLoader().load("models/obj/head.obj").then((mesh) {
      orange.root.addChild(new Node("head")
          ..addComponent(new MeshFilter(mesh))
          ..addComponent(new MeshRenderer()..materials = [material3]));
    });

    orange.root.addChild(new Node("cube")
        ..addComponent(new MeshFilter(CubeGenerator.create()))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("cube").transform.translate(0.0, -0.5, 0.0);

    orange.root.addChild(new Node("circle")
        ..addComponent(new MeshFilter(CircleGenerator.create(2.0)))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("circle").transform.rotateX(-PI2 / 2);
    orange.root.findChild("circle").transform.translate(0.0, -0.5, 0.0);

    orange.root.addChild(new Node("cylinder")
        ..addComponent(new MeshFilter(CylinderGenerator.create()))
        ..addComponent(new MeshRenderer()..materials = [material2]));
    orange.root.findChild("cylinder").transform.translate(-3.0, 1.0, -2.0);

    orange.root.addChild(new Node("ring")
        ..addComponent(new MeshFilter(RingGenerator.create(0.5, 2.5)))
        ..addComponent(new MeshRenderer()..materials = [material2]));
    orange.root.findChild("ring").transform.translate(3.0, 1.0, -5.0);

    orange.root.addChild(new Node("sphere")
        ..addComponent(new MeshFilter(SphereGenerator.create()))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("sphere").transform.translate(-2.0, 2.0, -5.0);

    orange.root.addChild(new Node("plane")
        ..addComponent(new MeshFilter(PlaneGenerator.create()))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("plane").transform.translate(0.0, 2.0, -5.0);
    orange.root.findChild("plane").transform.scale = new Vector3.all(5.0);

    orange.mainCamera.transform.translate(0.0, 1.0, 5.0);
  };

  orange.enterFrame = (GameTime gameTime) {
    var head = orange.root.findChild("head");
    if (head != null) head.transform.rotateY(gameTime.elapsed / 1000.0);

    var cube = orange.root.findChild("cube");
    if (cube != null) cube.transform.rotateY(gameTime.elapsed / 1000.0);

    var ring = orange.root.findChild("ring");
    if (ring != null) {
      ring.transform.rotateY(gameTime.elapsed / 1000.0);
      ring.transform.rotateX(gameTime.elapsed / 1000.0);
    }

    var cylinder = orange.root.findChild("cylinder");
    if (cylinder != null) {
      cylinder.transform.rotateY(gameTime.elapsed / 1000.0);
      cylinder.transform.rotateX(gameTime.elapsed / 1000.0);
    }

    var sphere = orange.root.findChild("sphere");
    if (sphere != null) {
      sphere.transform.rotateY(gameTime.elapsed / 1000.0);
      sphere.transform.rotateX(gameTime.elapsed / 1000.0);
    }
  };

  orange.exitFrame = () {

  };

  orange.run();

}


