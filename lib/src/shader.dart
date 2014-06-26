part of orange;



class Shader {
  bool ready = false;

  gl.RenderingContext _ctx;
  gl.Program program;
  gl.Shader _vertexShader, _fragmentShader;
  Map<String, ShaderProperty> attributes;
  Map<String, ShaderProperty> uniforms;
  List<String> sampers;

  Shader(this._ctx, String vertSrc, String fragSrc, {String common: ""}) {
    _initialize(vertSrc, fragSrc, common: common);
  }

  /**
   * vertex source file:   ${url}VS.glsl
   * fragment source file: ${url}FS.glsl
   **/
  Shader.load(String url) {
    Future.wait([html.HttpRequest.getString("${url}VS.glsl"), html.HttpRequest.getString("${url}FS.glsl")]).then((r) => _initialize(r[0], r[1]));
  }

  _initialize(String vertSrc, String fragSrc, {String common: ""}) {
    _vertexShader = _compileShader(_ctx, "$common\n$vertSrc", gl.VERTEX_SHADER);
    _fragmentShader = _compileShader(_ctx, "$common\n$fragSrc", gl.FRAGMENT_SHADER);
    program = _ctx.createProgram();
    _ctx.attachShader(program, _vertexShader);
    _ctx.attachShader(program, _fragmentShader);
    _ctx.linkProgram(program);
    if (!_ctx.getProgramParameter(program, gl.LINK_STATUS)) {
      dispose();
    } else {
      attributes = {};
      var attribCount = _ctx.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
      for (var i = 0; i < attribCount; i++) {
        var info = _ctx.getActiveAttrib(program, i);
        attributes[info.name] = new ShaderProperty(info.name, _ctx.getAttribLocation(program, info.name), info.type);
      }

      uniforms = {};
      sampers = [];
      var uniformCount = _ctx.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
      for (var i = 0; i < uniformCount; i++) {
        var uniform = _ctx.getActiveUniform(program, i);
        var name = uniform.name;
        var ii = name.indexOf("[0]");
        if (ii != -1) {
          name = name.substring(0, ii);
        }
        uniforms[name] = new ShaderProperty(name, _ctx.getUniformLocation(program, name), uniform.type);
        if(uniform.type == gl.SAMPLER_2D || uniform.type == gl.SAMPLER_CUBE) {
          sampers.add(name);
        }
      }
      ready = true;
    }
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

  void dispose() {
    if (program != null) {
      _ctx.deleteProgram(program);
      _ctx.deleteShader(_vertexShader);
      _ctx.deleteShader(_fragmentShader);
    }
  }
}

class ShaderProperty {
  String name;
  dynamic location;
  int type;
  ShaderProperty(this.name, this.location, this.type);
}
