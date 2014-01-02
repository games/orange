library orange;

// Make it robust
// 1) detecting WebGL support in the browser
// 2) detecting a lost context


import 'dart:html' as html;
import 'dart:convert' show JSON;
import 'dart:web_gl' as gl;
import 'dart:math' as math;
import 'dart:typed_data';
//import 'package:vector_math/vector_math.dart';
import 'dart:mirrors';
import 'dart:async';


part 'src/node.dart';
part 'src/camera.dart';
part 'src/mesh.dart';
part 'src/primitive.dart';
part 'src/buffer.dart';
part 'src/buffer_view.dart';
part 'src/indices.dart';
part 'src/material.dart';
part 'src/mesh_attribute.dart';
part 'src/loader.dart';
part 'src/string_helper.dart';
part 'src/image.dart';
part 'src/scene.dart';
part 'src/renderer.dart';
part 'src/director.dart';
part 'src/technique.dart';
part 'src/program.dart';
part 'src/pass.dart';
part 'src/sampler.dart';
part 'src/texture.dart';
part 'src/shader.dart';
part 'src/only_once.dart';
part 'src/resources.dart';
part 'src/light.dart';
part 'src/trackball_controls.dart';
part 'src/color.dart';

part 'src/materials/color_material.dart';
part 'src/materials/texture_material.dart';

part 'src/math/matrix4.dart';
part 'src/math/matrix3.dart';
part 'src/math/vector3.dart';
part 'src/math/quaternion.dart';
part 'src/math/angle.dart';

part 'src/event/eventdispatcher.dart';
part 'src/event/events.dart';
part 'src/event/eventsubscription.dart';


final Vector3 WORLD_UP = new Vector3(0.0, 1.0, 0.0);
final Vector3 WORLD_LEFT = new Vector3(-1.0, 0.0, 0.0);
final Vector3 WORLD_RIGHT = new Vector3(1.0, 0.0, 0.0);
final Vector3 WORLD_DOWN = new Vector3(0.0, -1.0, 0.0);

final Vector3 UNIT_X = new Vector3(1.0, 0.0, 0.0);
final Vector3 UNIT_Y = new Vector3(0.0, 1.0, 0.0);
final Vector3 UNIT_Z = new Vector3(0.0, 0.0, 1.0);







