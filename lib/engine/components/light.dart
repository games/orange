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

part of orange;



class Light extends Component {
  static const int DIRECTIONAL = 1;
  static const int POINT = 2;
  static const int SPOT = 3;
  static const int HEMISPHERIC = 4;

  /// The current type of light object: 1=Directional, 2=Point, 3=Spot, 4=Hemispheric
  int type = 0;
  /// Brightness of the light.
  double intensity = 1.0;
  bool enabled = true;
  /// The color of the light emitted.
  Color4 diffuse = new Color4.all(1.0);
  Color3 specular = new Color3.all(1.0);

  /// How far light is emitted from the center of the object. Point/Spot light only.
  double range = double.MAX_FINITE;

  /// Directional & Spot & Hemispheric
  /// TODO calculate from transform
  Vector3 direction = new Vector3(-0.8, -1.0, -0.4).normalize();

  /// Spot Light
  double exponent = 3.0;
  /// Determines the angle of the cone in degrees. Spot light only.
  double angle = 0.8;

  /// Hemispheric light only
  Color4 groundColor = new Color4.zero();

  Light.directional() : type = DIRECTIONAL;
  Light.point() : type = POINT;
  Light.spot() : type = SPOT;
  Light.hemispheric() : type = HEMISPHERIC;

  @override
  void onStart() {
  }

  @override
  void onUpdate(GameTime time) {
  }
}
