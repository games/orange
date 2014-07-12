library orange_examples;

import 'dart:html' as html;
import 'dart:math';
import 'dart:async';
import 'dart:web_gl' as gl;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'package:vector_math/vector_math.dart';

part 'test_boundingbox.dart';
part 'test_physics.dart';
part 'test_animation.dart';
part 'test_lighting.dart';
part 'test_lighting2.dart';
part 'test_gltf.dart';
part 'test_textures.dart';
part 'test_water.dart';
part 'test_babylon_ship.dart';
part 'test_babylon_viper.dart';
part 'test_particles.dart';
part 'test_obj_loader.dart';
part 'test_physically_based_render.dart';
part 'test_physically_based_render2.dart';
part 'test_octree.dart';
part 'test_babylon_wcafe.dart';
part 'test_billboard.dart';




void main() {
  var canvas = html.querySelector("#container");
  var graphics = new GraphicsDevice(canvas);
  var camera = new PerspectiveCamera(canvas.width / canvas.height, near: 1.0, far: 10000.0);
  camera.translate(0.0, 0.0, 4.0);
  var controller = new ArcRotateController();
  controller.attach(camera, canvas);

  var stats = new Stats();
  html.querySelector("#stat").children.add(stats.container);

  var orange = new Orange(graphics);

  var scenes = [new TestAnimationScene(camera), 
                new TestBoundingBoxScene(camera), 
                new TestLightingScene(camera), 
                new TestLightingScene2(camera), 
                new PhysicsScene(camera), 
                new TestGLTFScene(camera), 
                new TestTexturesScene(camera), 
                new TestWaterScene(camera), 
                new TestBabylonShipScene(camera), 
                new TestBabylonViperScene(camera), 
                new TestParticles(camera), 
                new TestObjLoader(camera), 
                new TestPhysicallyBasedRender(camera), 
                new TestPhysicallyBasedRender2(camera), 
                new TestOctree(camera), 
                new TestBabylonWCafeScene(camera), 
                new TestBillboardScene(camera)];

  var i = scenes.length - 1;

  orange.enter(scenes[i]);
  orange.run();
  orange.afterRenders.add(() {
    stats.end();
    stats.begin();
  });

  var controllers = html.querySelector("#controllers");
  var selector = html.querySelector("#scenes") as html.SelectElement;
  selector.selectedIndex = i;
  selector.onChange.listen((e) {
    controllers.children.clear();

    controller.attach(camera, canvas);
    orange.enter(scenes[int.parse(selector.value)]);
  });

}

void addControls(html.Element control) {
  html.querySelector("#controllers").children.add(control);
}

html.Element createRadio(String id, String group, String desc, handler, [bool selected = false]) {
  var row = createRow();
  var radio = new html.RadioButtonInputElement();
  radio.id = id;
  radio.name = group;
  radio.value = group;
  radio.checked = selected;
  radio.onClick.listen(handler);
  var label = new html.LabelElement();
  label.htmlFor = radio.id;
  label.text = desc;
  row.children.add(radio);
  row.children.add(label);
  return row;
}

html.DivElement createRow() {
  var row = new html.DivElement();
  row.className = "row";
  return row;
}









