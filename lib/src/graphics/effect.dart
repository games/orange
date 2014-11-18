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




/// effect contain code that defines what kind of properties and assets to use.
class Effect implements Disposable {

  gl.Program program;
  gl.Shader vertexShader;
  gl.Shader fragmentShader;
  EffectParameters attributes;
  EffectParameters uniforms;
  List<String> samplers;

  bool _ready = false;
  bool get ready => _ready;

  String _vertSrc, _fragSrc, _commonSrc;
  set commonSrc(String value) => _commonSrc = value;

  Effect()
      : attributes = new EffectParameters(),
        uniforms = new EffectParameters(),
        samplers = [],
        _commonSrc = "";

  Effect.source(this._vertSrc, this._fragSrc, {String common: ""})
      : attributes = new EffectParameters(),
        uniforms = new EffectParameters(),
        samplers = [] {
    _commonSrc = common;
  }

  /// vertex source file:   [url].vs.glsl
  /// fragment source file: [url].fs.glsl
  Effect.load(String url, {String common: ""})
      : attributes = new EffectParameters(),
        uniforms = new EffectParameters(),
        samplers = [] {
    Future.wait([html.HttpRequest.getString("${url}.vs.glsl"), html.HttpRequest.getString("${url}.fs.glsl")]).then((r) {
      _vertSrc = r[0];
      _fragSrc = r[1];
      _commonSrc = common;
    });
  }

  bool prepare(RenderData renderData) => !_ready && _vertSrc != null && _fragSrc != null;

  compile(RenderData renderData) {

    if (!prepare(renderData)) return;

    var graphics = Orange.instance.graphicsDevice;
    var ctx = graphics._ctx;

    vertexShader = _compileShader(ctx, "$_commonSrc\n$_vertSrc", gl.VERTEX_SHADER);
    if (vertexShader == null) return;

    fragmentShader = _compileShader(ctx, "$_commonSrc\n$_fragSrc", gl.FRAGMENT_SHADER);
    if (fragmentShader == null) return;

    program = ctx.createProgram();
    ctx.attachShader(program, vertexShader);
    ctx.attachShader(program, fragmentShader);
    ctx.linkProgram(program);
    if (!ctx.getProgramParameter(program, gl.LINK_STATUS)) {
      dispose();
      return;
    }

    var attribCount = ctx.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
    for (var i = 0; i < attribCount; i++) {
      var info = ctx.getActiveAttrib(program, i);
      attributes.update(info.name, ctx.getAttribLocation(program, info.name), info.type);
    }

    var uniformCount = ctx.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
    for (var i = 0; i < uniformCount; i++) {
      var uniform = ctx.getActiveUniform(program, i);
      var name = uniform.name;
      var ii = name.indexOf("[0]");
      if (ii != -1) {
        name = name.substring(0, ii);
      }
      uniforms.update(name, ctx.getUniformLocation(program, name), uniform.type);
      if (uniform.type == gl.SAMPLER_2D || uniform.type == gl.SAMPLER_CUBE) {
        samplers.add(name);
      }
    }

    _ready = true;
    _vertSrc = null;
    _fragSrc = null;
    _commonSrc = null;
  }

  gl.Shader _compileShader(gl.RenderingContext ctx, String source, int type) {
    var shader = ctx.createShader(type);
    ctx.shaderSource(shader, source);
    ctx.compileShader(shader);
    var s = ctx.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (ctx.getShaderParameter(shader, gl.COMPILE_STATUS) == false) {
      print(ctx.getShaderInfoLog(shader));
      ctx.deleteShader(shader);
      return null;
    }
    return shader;
  }

  @override
  void dispose() {
    if (program != null) {
      var ctx = Orange.instance.graphicsDevice._ctx;
      ctx.deleteProgram(program);
      ctx.deleteShader(vertexShader);
      ctx.deleteShader(fragmentShader);
    }
  }
  
  static String jointAsDefines(List<String> defines) => defines.fold("", (r, e) => r += "#define " + e + "\n");
}
