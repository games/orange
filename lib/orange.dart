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
import 'dart:async';
import 'dart:mirrors';


part 'src/director.dart';
part 'src/once.dart';
part 'src/color.dart';
part 'src/camera.dart';
part 'src/scene.dart';
part 'src/node.dart';
part 'src/shader.dart';
part 'src/texture.dart';
part 'src/mesh.dart';
part 'src/renderer.dart';
part 'src/renderer_new.dart';
part 'src/built_in_shaders.dart';
part 'src/animation/keyframe.dart';
part 'src/buffer_view.dart';
part 'src/semantics.dart';
part 'src/sampler.dart';
part 'src/materials/pass.dart';
part 'src/light.dart';
part 'src/geometry.dart';
part 'src/materials/technique.dart';

part 'src/primitives/polygon_mesh.dart';
part 'src/primitives/cube.dart';
part 'src/primitives/sphere.dart';
part 'src/primitives/plane.dart';
part 'src/primitives/cylinder.dart';
part 'src/primitives/coordinate.dart';

part 'src/animation/joint.dart';
part 'src/animation/animation_controller.dart';
part 'src/animation/skeleton.dart';
part 'src/animation/animation.dart';
part 'src/animation/track.dart';

part 'src/loaders/wgl_loader.dart';
part 'src/loaders/gltf_loader.dart';
part 'src/loaders/ogre_loader.dart';
part 'src/loaders/obj_loader.dart';

part 'src/math/matrix4.dart';
part 'src/math/matrix3.dart';
part 'src/math/vector2.dart';
part 'src/math/vector3.dart';
part 'src/math/vector4.dart';
part 'src/math/quaternion.dart';
part 'src/math/angle.dart';

part 'src/materials/material.dart';
part 'src/materials/standard_material.dart';

part 'src/shaders/standard_shader.dart';



or(expectValue, defaultValue) {
  if(expectValue == null) 
    return defaultValue;
  return expectValue;
}

capitalize(String str) => str[0].toUpperCase() + str.substring(1);


abstract class Axis {
  static final Vector3 X = new Vector3(1.0, 0.0, 0.0);
  static final Vector3 Y = new Vector3(0.0, 1.0, 0.0);
  static final Vector3 Z = new Vector3(0.0, 0.0, 1.0);
}

typedef void Callback();
typedef void Callback1<T>();
typedef void Callback2<T1, T2>();




























