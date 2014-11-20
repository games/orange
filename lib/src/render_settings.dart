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


/// refer: http://docs.unity3d.com/Manual/class-RenderSettings.html
class RenderSettings {
  static int FOGMODE_NONE = 0;
  static int FOGMODE_EXP = 1;
  static int FOGMODE_EXP2 = 2;
  static int FOGMODE_LINEAR = 3;
  
  /// If enabled, fog will be drawn throughout your scene.
  bool fog = false;
  /// Color of the fog.
  Color4 fogColor;
  /// Fog mode: Linear, Exponential (Exp) or Exponential Squared (Exp2). 
  /// This controls the way fog fades in with distance.
  int fogMode;
  /// Density of the fog; only used by Exp and Exp2 fog modes.
  num fogDensity = 0.1;
  /// Start and End distances of the fog; only used by Linear fog mode.
  num fogStart = 0.0;
  num fogEnd = 1000.0;
  /// Color of the scene’s ambient light.
  Color3 ambientLight = new Color3.all(0.0);
  /// Default skybox that will be rendered for cameras that have no skybox attached.
  Texture skyboxTexture;
  
  // TODO
  num haloStrength = 0.5;
  num flareStrength = 1;
  num flareFadeSpeed = 3;
  Texture haloTexture;
  Texture spotCookie;
}










