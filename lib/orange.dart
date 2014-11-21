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



part 'engine/disposable.dart';
part 'engine/orange.dart';
part 'engine/node.dart';
part 'engine/component.dart';
part 'engine/game_time.dart';
part 'engine/mesh.dart';
part 'engine/render_settings.dart';

part 'engine/resources/resource_manager.dart';
part 'engine/resources/texture_loader.dart';
part 'engine/resources/obj_loader.dart';
part 'engine/resources/cube_generator.dart';
part 'engine/resources/circle_generator.dart';
part 'engine/resources/cylinder_generator.dart';
part 'engine/resources/ring_generator.dart';
part 'engine/resources/sphere_generator.dart';
part 'engine/resources/plane_generator.dart';

part 'engine/graphics/graphics_device.dart';
part 'engine/graphics/vertex_buffer.dart';
part 'engine/graphics/material.dart';
part 'engine/graphics/texture.dart';
part 'engine/graphics/sampler.dart';
part 'engine/graphics/shader.dart';
part 'engine/graphics/technique.dart';
part 'engine/graphics/render_state.dart';
part 'engine/graphics/pass.dart';

part 'engine/graphics/effects/effect.dart';
part 'engine/graphics/effects/effect_parameters.dart';
part 'engine/graphics/effects/render_data.dart';
part 'engine/graphics/effects/skybox_effect.dart';


part 'engine/components/transform.dart';
part 'engine/components/camera.dart';
part 'engine/components/perspective_camera.dart';
part 'engine/components/mesh_filter.dart';
part 'engine/components/mesh_renderer.dart';
part 'engine/components/light.dart';

part 'engine/math/matrix4.dart';
part 'engine/math/matrix3.dart';
part 'engine/math/quaternion.dart';
part 'engine/math/vector2.dart';
part 'engine/math/vector3.dart';
part 'engine/math/vector4.dart';
part 'engine/math/color.dart';
part 'engine/math/ray.dart';
part 'engine/math/bounding_info.dart';







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



