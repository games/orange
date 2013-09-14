library orange;


import 'dart:html' as html;
import 'dart:json' as json;
import 'dart:web_gl' as gl;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';


part 'src/engine.dart';
part 'src/transform.dart';
part 'src/camera.dart';
part 'src/mesh.dart';
part 'src/geometry.dart';
part 'src/material.dart';
part 'src/renderer.dart';
part 'src/shader.dart';




Engine _engine;

initOrange(html.CanvasElement canvas) {
  _engine = new Engine._internal(canvas);
}

Engine get Orange {
  return _engine;
}