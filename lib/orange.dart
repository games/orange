library orange;

// Make it robust
// 1) detecting WebGL support in the browser
// 2) detecting a lost context


import 'dart:html' as html;
import 'dart:convert' show JSON;
import 'dart:web_gl' as gl;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'dart:async';
import 'dart:mirrors';
import 'dart:js' as JS;


part 'src/orange.dart';
part 'src/once.dart';
part 'src/color.dart';
part 'src/scene.dart';
part 'src/node.dart';
part 'src/shader.dart';
part 'src/mesh.dart';
part 'src/graphics_device.dart';
part 'src/built_in_shaders.dart';
part 'src/vertex_buffer.dart';
part 'src/semantics.dart';
part 'src/sampler.dart';
part 'src/geometry.dart';
part 'src/disposable.dart';

part 'src/cameras/camera.dart';
part 'src/cameras/orbit_controller.dart';
part 'src/cameras/arc_rotate_controller.dart';

part 'src/primitives/polygon_mesh.dart';
part 'src/primitives/cube.dart';
part 'src/primitives/sphere_mesh.dart';
part 'src/primitives/plane_mesh.dart';
part 'src/primitives/cylinder.dart';
part 'src/primitives/coordinate.dart';

part 'src/animation/keyframe.dart';
part 'src/animation/joint.dart';
part 'src/animation/animation_controller.dart';
part 'src/animation/skeleton.dart';
part 'src/animation/animation.dart';
part 'src/animation/track.dart';

part 'src/loaders/gltf_loader.dart';
part 'src/loaders/ogre_loader.dart';
part 'src/loaders/obj_loader.dart';
part 'src/loaders/babylon_loader.dart';
part 'src/loaders/loader_utils.dart';

//part 'src/math/matrix4.dart';
//part 'src/math/matrix3.dart';
//part 'src/math/vector2.dart';
//part 'src/math/vector3.dart';
//part 'src/math/vector4.dart';
//part 'src/math/quaternion.dart';
//part 'src/math/angle.dart';
part 'src/math/utils.dart';
part 'src/math/matrix.dart';

part 'src/materials/material.dart';
part 'src/materials/shader_material.dart';
part 'src/materials/standard_material.dart';
part 'src/materials/physically_based_material.dart';
part 'src/materials/water_material.dart';
part 'src/materials/technique.dart';
part 'src/materials/pass.dart';
part 'src/materials/texture.dart';
part 'src/materials/cube_texture.dart';
part 'src/materials/mirror_texture.dart';
part 'src/materials/render_target_texture.dart';

part 'src/shaders/standard_shader.dart';
part 'src/shaders/shadowmap_shader.dart';
part 'src/shaders/color_shader.dart';
part 'src/shaders/water_shader.dart';
part 'src/shaders/particles_shader.dart';
part 'src/shaders/physically_based_shader.dart';

part 'src/lights/light.dart';

part 'src/physics/physics_engine.dart';
part 'src/physics/plugins/cannonjs.dart';

part 'src/culling/bounding_info.dart';
part 'src/culling/bounding_box.dart';
part 'src/culling/bounding_sphere.dart';
part 'src/culling/octrees/octree.dart';
part 'src/culling/octrees/octree_block.dart';

part 'src/rendering/shadow_renderer.dart';
part 'src/rendering/bounding_box_renderer.dart';
part 'src/rendering/rendering_group.dart';

part 'src/particles/particle.dart';
part 'src/particles/particle_system.dart';



or(expectValue, defaultValue) {
  if (expectValue == null) return defaultValue;
  return expectValue;
}

capitalize(String str) => str[0].toUpperCase() + str.substring(1);

double randomFloat(num min, num max) {
  if (min == max) return min.toDouble();
  var rnd = new math.Random();
  return rnd.nextDouble() * (max - min) + min;
}

abstract class Axis {
  static final Vector3 LEFT = new Vector3(1.0, 0.0, 0.0);
  static final Vector3 UP = new Vector3(0.0, 1.0, 0.0);
  static final Vector3 FRONT = new Vector3(0.0, 0.0, 1.0);

  static final Vector3 X = LEFT;
  static final Vector3 Y = UP;
  static final Vector3 Z = FRONT;
}

typedef void Callback();
typedef void Callback1<T>();
typedef void Callback2<T1, T2>();

























