part of orange;



class Shader {
  bool ready = false;
  
  gl.Program program;
  Map<String, ShaderProperty> attributes;
  Map<String, ShaderProperty> uniforms;
  
  Shader(gl.RenderingContext ctx, String vertexShader, String fragmentShader) {
    var vs = _compileShader(ctx, vertexShader, gl.VERTEX_SHADER);
    var fs = _compileShader(ctx, fragmentShader, gl.FRAGMENT_SHADER);
    program = ctx.createProgram();
    ctx.attachShader(program, vs);
    ctx.attachShader(program, fs);
    ctx.linkProgram(program);
    if(!ctx.getProgramParameter(program, gl.LINK_STATUS)) {
      ctx.deleteProgram(program);
      ctx.deleteShader(vs);
      ctx.deleteShader(fs);
    } else {
      attributes = {};
      var attribCount = ctx.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
      for(var i = 0; i < attribCount; i++) {
         var info = ctx.getActiveAttrib(program, i);
         attributes[info.name] = new ShaderProperty(info.name, ctx.getAttribLocation(program, info.name), info.type);
      }
      
      uniforms = {};
      var uniformCount = ctx.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
      for(var i = 0; i < uniformCount; i++) {
        var uniform = ctx.getActiveUniform(program, i);
        var name = uniform.name;
        var ii = name.indexOf("[0]");
        if(ii != -1) {
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