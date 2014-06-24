import 'package:orange/orange.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math';
import 'dart:html';




class TestBoundingBoxScene extends Scene {

  TestBoundingBoxScene(Camera camera): super(camera);

  Mesh box;

  @override
  void enter() {

    camera.setTranslation(0.0, 2.0, 4.0);
    camera.lookAt(new Vector3.zero());

    var material = new StandardMaterial();
    material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);

    box = new Cube(width: 0.5, height: 0.2, depth: 1);
    box.setTranslation(0.0, 0.0, -3.0);
    box.material = material;
    box.showBoundingBox = true;
    add(box);

    var sphere = new SphereMesh(radius: 0.5);
    sphere.setTranslation(2.0, 0.0, 0.0);
    sphere.material = new StandardMaterial();
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);
    sphere.showBoundingBox = true;
    add(sphere);

    var plane = new PlaneMesh(width: 2, height: 2);
    plane.rotate(Axis.X, -PI / 2);
    plane.setTranslation(0.0, 0.0, 0.0);
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.showBoundingBox = true;
    add(plane);

    var light0 = new PointLight(0xffffff);
    light0.position = new Vector3(-5.0, 3.0, 0.0);
    add(light0);
    
    var duplicateBox = new ButtonElement();
    duplicateBox.onClick.listen((e) {
      var rnd = new Random();
      var newBox = box.clone();
      newBox.setTranslation(rnd.nextDouble() * 4.0 - 2.0, rnd.nextDouble() * 3.0 - 1.0, rnd.nextDouble() * 2.0 - 1.0);
      newBox.scale(rnd.nextDouble());
      add(newBox);
    });
    duplicateBox.text = "Duplicate";
    querySelector("#controllers").children.add(duplicateBox);
  }

  @override
  void enterFrame(num elapsed, num interval) {
    nodes.forEach((node) {
      if (node is Mesh) {
        node.rotate(Axis.Y, sin(elapsed / 1000) * 2 * PI);
      }
    });

    box.position = new Vector3(0.0, 0.0, sin(elapsed / 1000) * 2.0);
  }
  
  @override
  void exit() {
    super.exit();
    removeChildren();
  }
}
