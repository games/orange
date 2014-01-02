part of orange;


class Program {
  List<String> attributes;
  Shader fragmentShader;
  Shader vertexShader;
  
  gl.Program program;
  gl.Shader fragment;
  gl.Shader vertex;
  Map<String, gl.ActiveInfo> symbolToActiveInfo;
  Map symbolToLocation;
  List<String> uniformSymbols;
  List<String> attributeSymbols;
  
  Program() {
    symbolToActiveInfo = new Map();
    symbolToLocation = new Map();
  }
  
  build(gl.RenderingContext ctx) {
    if(vertexShader.ready && vertex == null) {
      vertex = ctx.createShader(gl.VERTEX_SHADER);
      ctx.shaderSource(vertex, vertexShader.source);
      ctx.compileShader(vertex);
    } else if(vertex == null){
      vertexShader.load();
    }
    
    if(fragmentShader.ready && fragment == null) {
      fragment = ctx.createShader(gl.FRAGMENT_SHADER);
      ctx.shaderSource(fragment, fragmentShader.source);
      ctx.compileShader(fragment);
    } else if(fragment == null){
      fragmentShader.load();
    }
    
    if(program == null && vertex != null && fragment != null) {
      program = ctx.createProgram();
      ctx.attachShader(program, vertex);
      ctx.attachShader(program, fragment);
      ctx.linkProgram(program);
      
      var currentProgram = ctx.getParameter(gl.CURRENT_PROGRAM);
      ctx.useProgram(program);
      var uniformsCount = ctx.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
      var activeInfo;
      uniformSymbols = new List();
      for(var i = 0; i < uniformsCount; i++) {
        activeInfo = ctx.getActiveUniform(program, i);
        var name = activeInfo.name;
        var ii = name.indexOf("[0]");
        if(ii != -1) {
          name = name.substring(0, ii);
        }
        uniformSymbols.add(name);
        symbolToActiveInfo[name] = activeInfo;
        symbolToLocation[name] = ctx.getUniformLocation(program, name);
      }
      
      var attributesCount = ctx.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
      attributeSymbols = new List();
      for(var i = 0; i < attributesCount; i++) {
        activeInfo = ctx.getActiveAttrib(program, i);
        attributeSymbols.add(activeInfo.name);
        symbolToActiveInfo[activeInfo.name] = activeInfo;
        symbolToLocation[activeInfo.name] = ctx.getAttribLocation(program, activeInfo.name);
      }
    }
  }
  
  bool get ready => program != null;
  
  int getTypeForSymbol(String symbol) {
    var activeInfo = symbolToActiveInfo[symbol];
    if(activeInfo != null) return activeInfo.type;
    return null;
  }
  
  setValueForSymbol(gl.RenderingContext ctx, String symbol, value) {
    var location = symbolToLocation[symbol];
    var type = getTypeForSymbol(symbol);
    switch(type) {
      case gl.FLOAT_MAT2:
        ctx.uniformMatrix2fv(location, false, value); break;
      case gl.FLOAT_MAT3:
        ctx.uniformMatrix3fv(location, false, _mat3f(value)); break;
      case gl.FLOAT_MAT4:
        ctx.uniformMatrix4fv(location, false, _mat4f(value)); 
        break;
      case gl.FLOAT:
        ctx.uniform1f(location, value); break;
      case gl.FLOAT_VEC2:
        ctx.uniform2fv(location, _vec(value, 2)); break;
      case gl.FLOAT_VEC3:
        ctx.uniform3fv(location, _vec(value, 3)); break;
      case gl.FLOAT_VEC4:
        ctx.uniform4fv(location, _vec(value, 4)); break;
      case gl.INT:
        ctx.uniform1i(location, value); break;
      case gl.SAMPLER_2D:
        ctx.uniform1i(location, value); break;
      case gl.SAMPLER_CUBE:
        ctx.uniform1i(location, value); break;
    }
  }
  
  _vec(List list, int length) {
    var l = new List(length);
    for(var i = 0; i < length; i++)
      l[i] = list[i].toDouble();
    return new Float32List.fromList(l);
  }
  
  _mat3f(Matrix3 mat) {
    var tmp = new Float32List(9);
    mat.copyIntoArray(tmp);
    return tmp;
  }
  
  _mat4f(Matrix4 mat) {
    var tmp = new Float32List(16);
    mat.copyIntoArray(tmp);
    return tmp;
  }
}















