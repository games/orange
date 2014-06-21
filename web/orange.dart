import 'dart:html' as html;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'show_boundingbox.dart';
import 'test_physics.dart';




void main() {
  var canvas = html.querySelector("#container");
  var renderer = new GraphicsDevice(canvas);
  var camera = new PerspectiveCamera(canvas.width / canvas.height);
  camera.position.setValues(0.0, 2.0, 4.0);
  camera.lookAt(new Vector3.zero());
      
  var director = new Director(renderer);
  
//  director.replace(new ShowBoundingBoxScene(camera));
  director.replace(new PhysicsScene(camera));
  director.run();


  //  new TestShadow().run();
//  new TestRenderer().run();
  //    new TestAnimation().run();
  //  testPhysics();
}












