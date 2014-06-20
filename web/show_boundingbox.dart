import 'package:orange/orange.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math';





class ShowBoundingBoxScene extends Scene {

  ShowBoundingBoxScene(PerspectiveCamera camera): super(camera);


  @override
  void enter() {

    var material = new StandardMaterial();
    material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);

    var box = new Cube();
    box.position.setValues(0.0, 0.0, -3.0);
    box.material = material;
    box.showBoundingBox = true;
    add(box);
    
    var sphere = new SphereMesh(radius: 0.5);
    sphere.position.setValues(2.0, 0.0, 0.0);
    sphere.material = new StandardMaterial();
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);
    sphere.showBoundingBox = true;
    add(sphere);
    
    var plane = new PlaneMesh(width: 2, height: 2);
    plane.rotation.setAxisAngle(Axis.X, -PI / 2);
    plane.position.setValues(0.0, 0.0, 0.0);
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.showBoundingBox = true;
    add(plane);

    var light0 = new PointLight(0xffffff);
    light0.position = new Vector3(-5.0, 3.0, 0.0);
    add(light0);
  }
  
  @override
  void enterFrame(num elapsed, num interval) {
    nodes.forEach((node) {
      if(node is Mesh) {
//        node.position.setValues(cos(elapsed / 1000) * 1.0, 0.0, sin(elapsed / 1000) * 1.0);
        node.rotation.setAxisAngle(Axis.Y, sin(elapsed / 1000) * 2 * PI);
      }
    });
  }
}
