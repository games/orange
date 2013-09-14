part of orange;


abstract class Shader {
  String name;
  String vertexSource;
  String fragmentSource;
  gl.Program program;
  
  compile();
}



class DefaultShader extends Shader {

  int vertexPositionAttribute;
  int vertexNormalAttribute;
  int vertexTextureAttribute;
  gl.UniformLocation pMatrixUniform;
  gl.UniformLocation mvMatrixUniform;
  gl.UniformLocation uNormalMatrix;
  gl.UniformLocation samplerUniform;
  Matrix4 pMatrix;
  
  DefaultShader._internal() {
    name = "default";
    vertexSource = """
        attribute vec3 aVertexPosition;
        attribute vec2 aTextureCoord;
        attribute highp vec3 aVertexNormal;

        uniform mat4 uNormalMatrix;
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;

        varying highp vec3 vLighting;
        varying vec2 vTextureCoord;

        void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

        vTextureCoord = aTextureCoord;

        //apply lighting effect
        highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
        highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
        highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);

        highp vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
        highp float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
        vLighting = ambientLight + (directionalLightColor * directional);
        }
        """;
    fragmentSource = """
        precision mediump float;

        uniform sampler2D uSampler;

        varying highp vec3 vLighting;

        varying vec2 vTextureCoord;

        void main(void) {
        vec4 texelColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
        gl_FragColor = vec4(texelColor.rgb * vLighting, 1.0);
        }
        """;
  }
  
  compile() {
    var ctx = _engine.renderer.ctx;
    gl.Shader vertexShader = ctx.createShader(gl.VERTEX_SHADER);
    ctx.shaderSource(vertexShader, vertexSource);
    ctx.compileShader(vertexShader);

    gl.Shader fragmentShader = ctx.createShader(gl.FRAGMENT_SHADER);
    ctx.shaderSource(fragmentShader, fragmentSource);
    ctx.compileShader(fragmentShader);
    
    program = ctx.createProgram();
    ctx.attachShader(program, vertexShader);
    ctx.attachShader(program, fragmentShader);
    ctx.linkProgram(program);
    ctx.useProgram(program);

    vertexPositionAttribute = ctx.getAttribLocation(program, "aVertexPosition");
    ctx.enableVertexAttribArray(vertexPositionAttribute);
    
    vertexNormalAttribute = ctx.getAttribLocation(program, "aVertexNormal");
    ctx.enableVertexAttribArray(vertexNormalAttribute);
    
    vertexTextureAttribute = ctx.getAttribLocation(program, "aTextureCoord");
    ctx.enableVertexAttribArray(vertexTextureAttribute);
    
    pMatrixUniform = ctx.getUniformLocation(program, "uPMatrix");
    mvMatrixUniform = ctx.getUniformLocation(program, "uMVMatrix");
    uNormalMatrix = ctx.getUniformLocation(program, "uNormalMatrix");
    samplerUniform = ctx.getUniformLocation(program, "uSampler");
  }
}











