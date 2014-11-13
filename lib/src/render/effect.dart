// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


part of orange;




/**
 * effect contain code that defines what kind of properties and assets to use.
 */
class Effect implements Disposable {

  gl.Program program;
  gl.Shader vertexShader;
  gl.Shader fragmentShader;
  Map<String, ProgramInput> attributes;
  Map<String, ProgramInput> uniforms;
  List<String> samplers;
  
  bool _ready = false;
  bool get ready => _ready;
  
  String _vertSrc, _fragSrc, _commonSrc;

  Effect(this._vertSrc, this._fragSrc, {String common: ""}) {
    _commonSrc = common;
  }

  /**
   * vertex source file:   [url].vs.glsl
   * fragment source file: [url].fs.glsl
   **/
  Effect.load(String url, {String common: ""}) {
    Future.wait([html.HttpRequest.getString("${url}.vs.glsl"), 
                 html.HttpRequest.getString("${url}.fs.glsl")]).then((r) {
      _vertSrc = r[0];
      _fragSrc = r[1];
      _commonSrc = common;
    });
  }
  
  void prepare() {
    if(_ready) return;
    _compile(_vertSrc, _fragSrc, common: _commonSrc);
    // I don't wanna store the source again
    _vertSrc = null;
    _fragSrc = null;
    _commonSrc = null;
  }

  _compile(String vertSrc, String fragSrc, {String common: ""}) {
    if(vertSrc == null || fragSrc == null) return;
    
    var graphics = Orange.instance.graphicsDevice;
    var ctx = graphics._ctx;

    vertexShader = _compileShader(ctx, "$common\n$vertSrc", gl.VERTEX_SHADER);
    if (vertexShader == null) return;

    fragmentShader = _compileShader(ctx, "$common\n$fragSrc", gl.FRAGMENT_SHADER);
    if (fragmentShader == null) return;

    program = ctx.createProgram();
    ctx.attachShader(program, vertexShader);
    ctx.attachShader(program, fragmentShader);
    ctx.linkProgram(program);
    if (!ctx.getProgramParameter(program, gl.LINK_STATUS)) {
      dispose();
      return;
    }

    attributes = {};
    var attribCount = ctx.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
    for (var i = 0; i < attribCount; i++) {
      var info = ctx.getActiveAttrib(program, i);
      attributes[info.name] = new ProgramInput(info.name, ctx.getAttribLocation(program, info.name), info.type);
    }

    uniforms = {};
    samplers = [];
    var uniformCount = ctx.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
    for (var i = 0; i < uniformCount; i++) {
      var uniform = ctx.getActiveUniform(program, i);
      var name = uniform.name;
      var ii = name.indexOf("[0]");
      if (ii != -1) {
        name = name.substring(0, ii);
      }
      uniforms[name] = new ProgramInput(name, ctx.getUniformLocation(program, name), uniform.type);
      if (uniform.type == gl.SAMPLER_2D || uniform.type == gl.SAMPLER_CUBE) {
        samplers.add(name);
      }
    }
    _ready = true;
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
}

