part of orange;



class Shader {
  bool ready = false;

  gl.Program program;
  Map<String, ShaderProperty> attributes;
  Map<String, ShaderProperty> uniforms;

  Shader(gl.RenderingContext ctx, String vertSrc, String fragSrc, {String common: ""}) {
    _initialize(ctx, vertSrc, fragSrc, common: common);
  }

  Shader.load(gl.RenderingContext ctx, String vertUrl, String fragUrl) {
    Future.wait([html.HttpRequest.getString(vertUrl), html.HttpRequest.getString(fragUrl)]).then((r) => _initialize(ctx, r[0], r[1]));
  }

  _initialize(gl.RenderingContext ctx, String vertSrc, String fragSrc, {String common: ""}) {
    var vertexShader = _compileShader(ctx, "$common\n$vertSrc", gl.VERTEX_SHADER);
    var fragmentShader = _compileShader(ctx, "$common\n$fragSrc", gl.FRAGMENT_SHADER);
    program = ctx.createProgram();
    ctx.attachShader(program, vertexShader);
    ctx.attachShader(program, fragmentShader);
    ctx.linkProgram(program);
    if (!ctx.getProgramParameter(program, gl.LINK_STATUS)) {
      ctx.deleteProgram(program);
      ctx.deleteShader(vertexShader);
      ctx.deleteShader(fragmentShader);
    } else {
      attributes = {};
      var attribCount = ctx.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
      for (var i = 0; i < attribCount; i++) {
        var info = ctx.getActiveAttrib(program, i);
        attributes[info.name] = new ShaderProperty(info.name, ctx.getAttribLocation(program, info.name), info.type);
      }

      uniforms = {};
      var uniformCount = ctx.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
      for (var i = 0; i < uniformCount; i++) {
        var uniform = ctx.getActiveUniform(program, i);
        var name = uniform.name;
        var ii = name.indexOf("[0]");
        if (ii != -1) {
          name = name.substring(0, ii);
        }
        uniforms[name] = new ShaderProperty(name, ctx.getUniformLocation(program, name), uniform.type);
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
}

class ShaderProperty {
  String name;
  dynamic location;
  int type;
  ShaderProperty(this.name, this.location, this.type);
}
