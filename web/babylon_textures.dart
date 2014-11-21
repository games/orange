library orange_examples;

import 'dart:math' as Math;
import 'package:orange/orange.dart';
import 'package:orange/babylon.dart';
import 'common.dart';



void main() {

  var orange = createOrange();

  orange.initialize = () {

    orange.renderSettings.ambientLight = new Color3.all(0.5);

    var ambientMaterial = Babylon.createMaterial();
    ambientMaterial.mainTexture = orange.resources.loadTexture("textures/wood.jpg");
    var effect = ambientMaterial.shader.technique.passes.first.effect as BabylonEffect;
    effect.ambientTexture = orange.resources.loadTexture("textures/firefox.png");

    var opacity = Babylon.createMaterial();
    opacity.mainTexture = orange.resources.loadTexture("textures/wood.jpg");
    effect = opacity.shader.technique.passes.first.effect as BabylonEffect;
    effect.opacityTexture = orange.resources.loadTexture("textures/ani2.jpg");
    effect.opacityFromRGB = true;

    var reflection = Babylon.createMaterial();
    reflection.mainTexture = orange.resources.loadTexture("textures/wood.jpg");
    effect = reflection.shader.technique.passes.first.effect as BabylonEffect;
    effect.reflectionTexture = orange.resources.loadTexture("textures/reflectiontexture.jpg");
    effect.coordinatesMode = BabylonEffect.SPHERICAL_MODE;

    var emissive = Babylon.createMaterial();
    emissive.mainTexture = orange.resources.loadTexture("textures/wood.jpg");
    effect = emissive.shader.technique.passes.first.effect as BabylonEffect;
    effect.emissiveTexture = orange.resources.loadTexture("textures/firefox.png");

    var specular = Babylon.createMaterial();
    specular.mainTexture = orange.resources.loadTexture("textures/wood.jpg");
    effect = specular.shader.technique.passes.first.effect as BabylonEffect;
    effect.specularTexture = orange.resources.loadTexture("textures/firefox.png");

    var bump = Babylon.createMaterial();
    bump.mainTexture = orange.resources.loadTexture("textures/wood.jpg");
    effect = bump.shader.technique.passes.first.effect as BabylonEffect;
    effect.bumpTexture = orange.resources.loadTexture("textures/bump.png");

    orange.root.addChild(new Node("sphereAmbient")
        ..addComponent(new MeshFilter(SphereGenerator.create(radius: 0.5)))
        ..addComponent(new MeshRenderer()..materials = [ambientMaterial]));

    orange.root.addChild(new Node("sphereOpacity")
        ..addComponent(new MeshFilter(SphereGenerator.create(radius: 0.5)))
        ..addComponent(new MeshRenderer()..materials = [opacity]));

    orange.root.addChild(new Node("sphereReflection")
        ..addComponent(new MeshFilter(SphereGenerator.create(radius: 0.5)))
        ..addComponent(new MeshRenderer()..materials = [reflection]));

    orange.root.addChild(new Node("sphereEmissive")
        ..addComponent(new MeshFilter(SphereGenerator.create(radius: 0.5)))
        ..addComponent(new MeshRenderer()..materials = [emissive]));

    orange.root.addChild(new Node("sphereSpecular")
        ..addComponent(new MeshFilter(SphereGenerator.create(radius: 0.5)))
        ..addComponent(new MeshRenderer()..materials = [specular]));

    orange.root.addChild(new Node("sphereBump")
        ..addComponent(new MeshFilter(SphereGenerator.create(radius: 0.5)))
        ..addComponent(new MeshRenderer()..materials = [bump]));

    var spheres = [
        "sphereAmbient",
        "sphereOpacity",
        "sphereReflection",
        "sphereEmissive",
        "sphereSpecular",
        "sphereBump"];
    for (var i = 0; i < spheres.length; i++) {
      var node = orange.root.findChild(spheres[i]);
      if (node != null) node.transform.translate((i - spheres.length / 2.0) * 1.1, 0.0, 0.0);
    }


    orange.root.addChild(new Node("light")
        ..addComponent(new Light.point()..diffuse = Color4.white())
        ..addComponent(new MeshFilter(SphereGenerator.create(widthSegments: 5, heightSegments: 5, radius: 0.1)))
        ..addComponent(new MeshRenderer()..materials = [ambientMaterial]));
    
    orange.root.findChild("light").transform.translate(1.0, 0.0, 0.0);
    
    orange.mainCamera.transform.translate(0.0, 0.0, 6.0);

//    orange.mainCamera.transform.applyMatrix(
//        new Matrix4.identity().lookAt(new Vector3(-5.0, 0.0, 6.0), new Vector3.zero(), Vector3.up).inverse());

  };

  orange.enterFrame = (GameTime gameTime) {
    var light = orange.root.findChild("light");
    if (light != null) {
      var t = gameTime.total / 600.0;
      light.transform.position = new Vector3(Math.sin(t) * 4.0, light.transform.position.y, Math.cos(t) * 4.0);
    }
  };

  orange.exitFrame = () {

  };

  orange.run();

}
