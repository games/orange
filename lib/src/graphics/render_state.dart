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



/// from: https://github.com/KhronosGroup/glTF/blob/master/specification/techniquePassStates.schema.json
class RenderState {
  
  bool blend = false;
  bool cullFaceEnabled = true;
  bool depthTest = true;
  bool polygonOffsetFill = false;
  bool sampleAlpahToCoverage = false;
  bool scissorTest = false;
  
  
  Color blendColor = Color.black();
  
  /// Integer values passed to blendEquationSeparate(). [rgb, alpha]. 
  /// Valid values are (32774) FUNC_ADD, (32778) FUNC_SUBTRACT, and (32779) FUNC_REVERSE_SUBTRACT.",
  List<int> blendEquationSeparate = [gl.FUNC_ADD, gl.FUNC_ADD];
  
  /// Integer values passed to blendFuncSeparate(). 
  /// [srcRGB, srcAlpha, dstRGB, dstAlpha]. 
  /// Valid values are 
  ///  (0) ZERO, (1) ONE, (768) SRC_COLOR, (769) ONE_MINUS_SRC_COLOR, (774) DST_COLOR, 
  ///  (775) ONE_MINUS_DST_COLOR, (770) SRC_ALPHA, (771) ONE_MINUS_SRC_ALPHA, (772) DST_ALPHA, 
  ///  (773) ONE_MINUS_DST_ALPHA, (32769) CONSTANT_COLOR, (32770) ONE_MINUS_CONSTANT_COLOR, (32771) CONSTANT_ALPHA, 
  ///  (32772) ONE_MINUS_CONSTANT_ALPHA, and (776) SRC_ALPHA_SATURATE.
  List<int> blendFuncSeparate = [gl.ONE, gl.ONE, gl.ZERO, gl.ZERO];
  
  /// Boolean values passed to colorMask(). [red, green, blue, alpha].
  List<bool> colorMask = [true, true, true, true];
  
  /// Integer value passed to cullFace(). Valid values are (1028) FRONT, (1029) BACK, and (1032) FRONT_AND_BACK.
  int cullFace = gl.BACK;
  
  /// Integer values passed to depthFunc(). 
  /// Valid values are 
  ///   (512) NEVER, (513) LESS, (515) LEQUAL, (514) EQUAL, (516) GREATER, (517) NOTEQUAL, (518) GEQUAL, and (519) ALWAYS.
  int depthFunc = gl.LESS;
  
  /// Boolean value passed to depthMask().
  /// specifies whether the depth buffer is enabled for writing.
  bool depthMask = true;
  
  /// Floating-point values passed to depthRange(). [zNear, zFar]
  List<double> depthRange = [0.0, 1.0];
  
  /// Integer value passed to frontFace().  Valid values are (2304) CW and (2305) CCW.
  int frontFace = gl.CCW;
  
  /// Floating-point value passed to lineWidth(). 0.0 ~ 1.0
  double lineWidth = 1.0;
  
  /// Floating-point value passed to polygonOffset().  [factor, units]
  List<double> polygonOffset;
  
  /// Floating-point value passed to scissor().  [x, y, width, height].  
  /// The defaults is the dimensions of the canvas when the WebGL context is created.  
  /// width and height must be > 0.0.
  List<double> scissor;
  
  
}
















