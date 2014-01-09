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
//import 'dart:mirrors';
import 'dart:async';


part 'src/camera.dart';
part 'src/node.dart';
part 'src/shader.dart';
part 'src/texture.dart';
part 'src/mesh.dart';
part 'src/lightmap.dart';
part 'src/renderer.dart';
part 'src/built_in_shaders.dart';
part 'src/joint.dart';
part 'src/animation.dart';
part 'src/keyframe.dart';
part 'src/mesh_attribute.dart';
part 'src/skeleton.dart';
part 'src/semantics.dart';

part 'src/loaders/wgl_loader.dart';

part 'src/math/matrix4.dart';
part 'src/math/matrix3.dart';
part 'src/math/vector3.dart';
part 'src/math/quaternion.dart';
part 'src/math/angle.dart';



or(expectValue, defaultValue) {
  if(expectValue == null) 
    return defaultValue;
  return expectValue;
}






























