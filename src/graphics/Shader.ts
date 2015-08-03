module orange {

  function addLineNumbers(src: string) {
      var chunks = src.split("\n");
      for (let i = 0; i < chunks.length; i++) {
          chunks[i] = (i + 1) + ":\t" + chunks[i];
      }
      return chunks.join("\n");
  }

  function createShader(gl: WebGLRenderingContext, type: number, src: string) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, src);
    gl.compileShader(shader);
    var ok = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (!ok) {
      var error = gl.getShaderInfoLog(shader);
      var typeName = (type === gl.VERTEX_SHADER) ? "vertex" : "fragment";
      console.error("Failed to compile " + typeName + " shader:\n\n" + addLineNumbers(src) + "\n\n" + error) ;
    }
    return shader;
  }

  function createProgram(gl: WebGLRenderingContext, vertexShader: WebGLShader, fragmentShader: WebGLShader) {
      var program = gl.createProgram();
      gl.attachShader(program, vertexShader);
      gl.attachShader(program, fragmentShader);
      gl.linkProgram(program);
      var ok = gl.getProgramParameter(program, gl.LINK_STATUS);
      if (!ok) {
        var error = gl.getProgramInfoLog(program);
        console.error("Failed to link shader program. Error: " + error);
      }
      return program;
  }

  export class ShaderDefinition {
    atributes: Object;
    vshader: string;
    fshader: string;
  }

  export class ShaderInput {
    constructor(public graphicsDevice:GraphicsDevice, public name, public type: number,
                public location: number | WebGLUniformLocation) {}
  }

  export class  Shader {
    program: WebGLProgram;
    attributes: ShaderInput[];
    uniforms: ShaderInput[];
    samplers: ShaderInput[];

    constructor(public graphicsDevice: GraphicsDevice, public definition: ShaderDefinition) {
      var gl = graphicsDevice.gl;
      var vertexShader = createShader(gl, gl.VERTEX_SHADER, definition.vshader);
      var fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, definition.fshader);
      this.program = createProgram(gl, vertexShader, fragmentShader);
      gl.deleteShader(vertexShader);
      gl.deleteShader(fragmentShader);
      this.attributes = new Array<ShaderInput>();
      this.uniforms = new Array<ShaderInput>();
      this.samplers = new Array<ShaderInput>();

      var i = 0;
      var info: WebGLActiveInfo;
      var location: number | WebGLUniformLocation;

      var numAttributes = gl.getProgramParameter(this.program, gl.ACTIVE_ATTRIBUTES);
      while (i < numAttributes) {
        info = gl.getActiveAttrib(this.program, i++);
        location = gl.getAttribLocation(this.program, info.name);
        if (definition.atributes[info.name] === undefined) {
          console.error('Vertex shader attribute "' + info.name + '" is not mapped to a semantic in shader definition.');
        }
        var attr = new ShaderInput(graphicsDevice, definition.atributes[info.name], info.type, location);
        this.attributes.push(attr);
      }

      i = 0;
      var numUniforms = gl.getProgramParameter(this.program, gl.ACTIVE_UNIFORMS);
      while(i < numUniforms) {
        info = gl.getActiveUniform(this.program, i++);
        location = gl.getUniformLocation(this.program, info.name);
        if ((info.type === gl.SAMPLER_2D) || (info.type === gl.SAMPLER_CUBE)) {
            this.samplers.push(new ShaderInput(graphicsDevice, info.name, info.type, location));
        } else {
            this.uniforms.push(new ShaderInput(graphicsDevice, info.name, info.type, location));
        }
      }
    }

    destroy() {
      this.graphicsDevice.gl.deleteProgram(this.program);
    }
  }
}
