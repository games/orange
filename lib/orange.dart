/*
  Orange : Simplified BSD License

  Copyright (c) 2014, Valor Zhong
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
  following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
     disclaimer.
    
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
     following disclaimer in the documentation and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
 */

library orange;



import 'dart:html' as html;
import 'dart:convert' show JSON;
import 'dart:web_gl' as gl;
import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:async';
import 'dart:js' as JS;



part 'src/disposable.dart';
part 'src/orange.dart';
part 'src/node.dart';
part 'src/component.dart';
part 'src/game_time.dart';
part 'src/mesh.dart';
part 'src/render_settings.dart';

part 'src/resources/resource_manager.dart';
part 'src/resources/texture_loader.dart';
part 'src/resources/obj_loader.dart';
part 'src/resources/cube_generator.dart';
part 'src/resources/circle_generator.dart';
part 'src/resources/cylinder_generator.dart';
part 'src/resources/ring_generator.dart';
part 'src/resources/sphere_generator.dart';
part 'src/resources/plane_generator.dart';

part 'src/graphics/graphics_device.dart';
part 'src/graphics/vertex_buffer.dart';
part 'src/graphics/material.dart';
part 'src/graphics/texture.dart';
part 'src/graphics/sampler.dart';
part 'src/graphics/shader.dart';
part 'src/graphics/technique.dart';
part 'src/graphics/render_state.dart';
part 'src/graphics/pass.dart';

part 'src/graphics/effects/effect.dart';
part 'src/graphics/effects/effect_parameters.dart';
part 'src/graphics/effects/render_data.dart';
part 'src/graphics/effects/textured_effect.dart';
part 'src/graphics/effects/skybox_effect.dart';


part 'src/components/transform.dart';
part 'src/components/camera.dart';
part 'src/components/perspective_camera.dart';
part 'src/components/mesh_filter.dart';
part 'src/components/mesh_renderer.dart';
part 'src/components/light.dart';

part 'src/math/matrix4.dart';
part 'src/math/matrix3.dart';
part 'src/math/quaternion.dart';
part 'src/math/vector2.dart';
part 'src/math/vector3.dart';
part 'src/math/vector4.dart';
part 'src/math/color.dart';
part 'src/math/ray.dart';
part 'src/math/bounding_info.dart';







typedef void Callback();
typedef void Callback1<T>(T t);


const double PI2 = Math.PI * 2.0;
const double degrees2radians = Math.PI / 180.0;
const double radians2degrees = 180.0 / Math.PI;

/// Convert [radians] to degrees.
double degrees(double radians) {
  return radians * radians2degrees;
}

/// Convert [degrees] to radians.
double radians(double degrees) {
  return degrees * degrees2radians;
}

or(expectValue, defaultValue) {
  if (expectValue == null) return defaultValue;
  return expectValue;
}

bool isPowerOfTwo(int x) => (x & (x - 1)) == 0;

int nextHighestPowerOfTwo(int x) {
  --x;
  for (var i = 1; i < 32; i <<= 1) {
    x = x | x >> i;
  }
  return x + 1;
}



