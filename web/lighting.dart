library orange_examples;

import 'dart:html' as Html;
import 'dart:math' as Math;
import 'dart:async';
import 'dart:web_gl' as gl;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';



void main() {
  var canvas = Html.querySelector("#container");
  canvas.width = Html.window.innerWidth;
  canvas.height = Html.window.innerHeight;

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
        ..addComponent(new MeshRenderer()..materials = [material3]));
    orange.root.findChild("cube").transform.translate(0.0, -0.5, 0.0);

    orange.root.addChild(new Node("circle")
        ..addComponent(new MeshFilter(CircleGenerator.create(3.0)))
        ..addComponent(new MeshRenderer()..materials = [material3]));
    orange.root.findChild("circle").transform.rotateX(-PI2 / 2);
    orange.root.findChild("circle").transform.translate(0.0, -0.5, 0.0);

    orange.root.addChild(new Node("cylinder")
        ..addComponent(new MeshFilter(CylinderGenerator.create(topRadius: 0.2, bottomRadius: 0.5)))
        ..addComponent(new MeshRenderer()..materials = [material3]));
    orange.root.findChild("cylinder").transform.translate(-1.0, 0.0, 1.0);
    orange.root.findChild("cylinder").transform.rotateX(PI2 / 8);

    orange.root.addChild(new Node("ring")
        ..addComponent(new MeshFilter(RingGenerator.create(0.5, 2.5)))
        ..addComponent(new MeshRenderer()..materials = [material3]));
    orange.root.findChild("ring").transform.translate(3.0, 1.0, -5.0);
    orange.root.findChild("ring").transform.rotateX(-PI2 / 8);

    orange.root.addChild(new Node("sphere")
        ..addComponent(new MeshFilter(SphereGenerator.create()))
        ..addComponent(new MeshRenderer()..materials = [material3]));
    orange.root.findChild("sphere").transform.translate(-2.0, 2.0, -5.0);

    orange.root.addChild(new Node("plane")
        ..addComponent(new MeshFilter(PlaneGenerator.create(width: 2.5)))
        ..addComponent(new MeshRenderer()..materials = [material3]));
    orange.root.findChild("plane").transform.translate(0.0, 2.0, -5.0);
    orange.root.findChild("plane").transform.scale = new Vector3.all(5.0);

    orange.root.addChild(new Node("redPoint")
        ..addComponent(new Light.point()..diffuse = Color4.red())
        ..addComponent(new MeshFilter(SphereGenerator.create(widthSegments: 5, heightSegments: 5, radius: 0.1)))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("redPoint").transform.translate(0.0, 2.0, 5.0);

    orange.root.addChild(new Node("greenPoint")
        ..addComponent(new Light.point()..diffuse = Color4.green())
        ..addComponent(new MeshFilter(SphereGenerator.create(widthSegments: 5, heightSegments: 5, radius: 0.1)))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("greenPoint").transform.translate(0.0, 2.0, -5.0);

    orange.root.addChild(new Node("bluePoint")
        ..addComponent(new Light.point()..diffuse = Color4.blue())
        ..addComponent(new MeshFilter(SphereGenerator.create(widthSegments: 5, heightSegments: 5, radius: 0.1)))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("bluePoint").transform.translate(5.0, 2.0, 0.0);

    orange.root.addChild(new Node("spotLight")
        ..addComponent(new Light.spot()..diffuse = new Color4(1.0, 1.0, 0.0, 1.0))
        ..addComponent(new MeshFilter(CylinderGenerator.create(topRadius: 0.03, bottomRadius: 0.08, height: 0.1)))
        ..addComponent(new MeshRenderer()..materials = [material]));
    orange.root.findChild("spotLight").transform.translate(1.0, 2.0, 2.0);

    orange.mainCamera.transform.translate(0.0, 1.0, 5.0);
  };

  orange.enterFrame = (GameTime gameTime) {
    var t = gameTime.total / 1000.0;

    var red = orange.root.findChild("redPoint");
    if (red != null) {
      red.transform.position = new Vector3(Math.cos(t) * 3.0, red.transform.position.y, Math.sin(t) * 3.0);
    }

    var green = orange.root.findChild("greenPoint");
    if (green != null) {
      green.transform.position = new Vector3(Math.sin(t) * 3.0, red.transform.position.y, Math.cos(t) * 3.0);
    }

    var blue = orange.root.findChild("bluePoint");
    if (blue != null) {
      t = gameTime.total / 600.0;
      blue.transform.position = new Vector3(Math.sin(t) * 3.0, red.transform.position.y, Math.cos(t) * 3.0);
    }
  };

  orange.exitFrame = () {

  };

  orange.run();

}
