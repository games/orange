library orange_examples;

import 'dart:html' as Html;
import 'package:orange/orange.dart';
import 'common.dart';



void main() {

  var orange = createOrange();

  orange.renderSettings.skyboxTexture = orange.resources.loadCubemapTexture("textures/cube/Bridge2/bridge");

  orange.initialize = () {
    var material = Material.defaultMaterial();
    material.mainTexture = orange.resources.loadTexture("textures/wood.jpg");

    orange.root.addChild(new Node("cube")
        ..addComponent(new MeshFilter(CubeGenerator.create()))
        ..addComponent(new MeshRenderer()..materials = [material]));
    
    orange.mainCamera.transform.translate(0.0, 0.0, 5.0);
  };
  
  orange.enterFrame = (GameTime time) {
    orange.mainCamera.transform.rotateY(time.elapsed / 1000);
  };
  

  orange.run();
}
