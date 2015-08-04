module orange {

  var glClearFlag: number[];
  var glAddress: number[];
  var glBlendEquation: number[];
  var glBlendFunction: number[];
  var glFilter: number[];
  var glPrimitive: number[];
  var glType: number[];

  export class GraphicsDevice {

    gl: WebGLRenderingContext;

    shader: Shader;
    attributesInvalidated: boolean;
    boundBuffer;
    indexBuffer;
    vertexBuffers;
    textureUnits: Texture[];
    renderTarget;
    scope: ScopeSpace;
    defaultClearOptions;

    width: number;
    height: number;
    blending: boolean;
    blendSrc: BlendMode;
    blendDst: BlendMode;
    blendEquation: BlendEquation;
    cullMode: CullMode;
    writeRed: boolean;
    writeBlue: boolean;
    writeGreen: boolean;
    writeAlpha: boolean;
    depthTest: boolean;
    depthWrite: boolean;
    clearDepth: number;
    clearRed: number;
    clearGreen: number;
    clearBlue: number;
    clearAlpha: number;
    capabilities: DeviceCapabilities;


    constructor(public canvas: HTMLCanvasElement) {
      var gl = this.createContext(canvas);
      this.gl = gl;

      glClearFlag = [
          0,
          gl.COLOR_BUFFER_BIT,
          gl.DEPTH_BUFFER_BIT,
          gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT,
          gl.STENCIL_BUFFER_BIT,
          gl.STENCIL_BUFFER_BIT | gl.COLOR_BUFFER_BIT,
          gl.STENCIL_BUFFER_BIT | gl.DEPTH_BUFFER_BIT,
          gl.STENCIL_BUFFER_BIT | gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
      ];

      glAddress = [
          gl.REPEAT,
          gl.CLAMP_TO_EDGE,
          gl.MIRRORED_REPEAT
      ];

      glBlendEquation = [
          gl.FUNC_ADD,
          gl.FUNC_SUBTRACT,
          gl.FUNC_REVERSE_SUBTRACT
      ];

      glBlendFunction = [
          gl.ZERO,
          gl.ONE,
          gl.SRC_COLOR,
          gl.ONE_MINUS_SRC_COLOR,
          gl.DST_COLOR,
          gl.ONE_MINUS_DST_COLOR,
          gl.SRC_ALPHA,
          gl.SRC_ALPHA_SATURATE,
          gl.ONE_MINUS_SRC_ALPHA,
          gl.DST_ALPHA,
          gl.ONE_MINUS_DST_ALPHA
      ];

      glFilter = [
          gl.NEAREST,
          gl.LINEAR,
          gl.NEAREST_MIPMAP_NEAREST,
          gl.NEAREST_MIPMAP_LINEAR,
          gl.LINEAR_MIPMAP_NEAREST,
          gl.LINEAR_MIPMAP_LINEAR
      ];

      glPrimitive = [
          gl.POINTS,
          gl.LINES,
          gl.LINE_LOOP,
          gl.LINE_STRIP,
          gl.TRIANGLES,
          gl.TRIANGLE_STRIP,
          gl.TRIANGLE_FAN
      ];

      glType = [
          gl.BYTE,
          gl.UNSIGNED_BYTE,
          gl.SHORT,
          gl.UNSIGNED_SHORT,
          gl.INT,
          gl.UNSIGNED_INT,
          gl.FLOAT
      ];

      this.capabilities = new DeviceCapabilities(gl);

      this.renderTarget = null;
      this.scope = new ScopeSpace("Device");

      this.defaultClearOptions = {
          color: [0, 0, 0, 1],
          depth: 1,
          flags: ClearFlags.COLOR | ClearFlags.DEPTH
      };

      this.textureUnits = new Array<Texture>(16);

      this.setBlending(false);
      this.setBlendFunction(gl.ONE, gl.ZERO);
      this.setBlendEquation(gl.FUNC_ADD);
      this.setColorWrite(true, true, true, true);
      this.setCullMode(CullMode.CULLFACE_BACK);
      this.setDepthTest(true);
      this.setDepthWrite(true);

      this.setClearDepth(1);
      this.setClearColor(0, 0, 0, 0);

      this.gl.enable(gl.SCISSOR_TEST);
    }

    setBlending(blending: boolean) {
      if (this.blending !== blending) {
        var gl = this.gl;
        if (blending) {
          gl.enable(gl.BLEND);
        } else {
          gl.disable(gl.BLEND);
        }
        this.blending = blending;
      }
    }

    setBlendFunction(blendSrc: BlendMode, blendDst: BlendMode) {
      if (this.blendSrc !== blendSrc ||
         this.blendDst !== blendDst) {
           this.gl.blendFunc(glBlendFunction[blendSrc], glBlendFunction[blendDst]);
           this.blendSrc = blendSrc;
           this.blendDst = blendDst;
         }
    }

    setBlendEquation(blendEquation: BlendEquation) {
      if (this.blendEquation !== blendEquation) {
        this.gl.blendEquation(glBlendEquation[blendEquation]);
        this.blendEquation = blendEquation;
      }
    }

    setCullMode(cullMode: CullMode) {
      if (this.cullMode !== cullMode) {
        switch(cullMode) {
          case CullMode.CULLFACE_NONE:
            this.gl.disable(this.gl.CULL_FACE);
            break;
          case CullMode.CULLFACE_FRONT:
            this.gl.enable(this.gl.CULL_FACE);
            this.gl.cullFace(this.gl.FRONT);
            break;
          case CullMode.CULLFACE_BACK:
            this.gl.enable(this.gl.CULL_FACE);
            this.gl.cullFace(this.gl.BACK);
            break;
          case CullMode.CULLFACE_FRONTANDBACK:
            this.gl.enable(this.gl.CULL_FACE);
            this.gl.cullFace(this.gl.FRONT_AND_BACK);
            break;
        }
        this.cullMode = cullMode;
      }
    }

    setColorWrite(writeRed: boolean, writeGreen: boolean, writeBlue: boolean, writeAlpha: boolean) {
      if ((this.writeRed !== writeRed) ||
          (this.writeGreen !== writeGreen) ||
          (this.writeBlue !== writeBlue) ||
          (this.writeAlpha !== writeAlpha)) {
          this.gl.colorMask(writeRed, writeGreen, writeBlue, writeAlpha);
          this.writeRed = writeRed;
          this.writeGreen = writeGreen;
          this.writeBlue = writeBlue;
          this.writeAlpha = writeAlpha;
      }
    }

    setDepthTest(depthTest: boolean) {
      if (this.depthTest !== depthTest) {
          var gl = this.gl;
          if (depthTest) {
              gl.enable(gl.DEPTH_TEST);
          } else {
              gl.disable(gl.DEPTH_TEST);
          }
          this.depthTest = depthTest;
      }
    }

    setDepthWrite(writeDepth: boolean) {
      if (this.depthWrite !== writeDepth) {
          this.gl.depthMask(writeDepth);
          this.depthWrite = writeDepth;
      }
    }

    setClearDepth(depth: number) {
      if (this.clearDepth !== depth) {
        this.gl.clearDepth(depth);
        this.clearDepth = depth;
      }
    }

    setClearColor(r: number, g: number, b: number, a: number) {
      if ((r !== this.clearRed) || (g !== this.clearGreen) || (b !== this.clearBlue) || (a !== this.clearAlpha)) {
          this.gl.clearColor(r, g, b, a);
          this.clearRed = r;
          this.clearGreen = g;
          this.clearBlue = b;
          this.clearAlpha = a;
      }
    }

    setViewport(x: number, y: number, width: number, height: number) {
      this.gl.viewport(x, y, width, height);
    }

    setScissor(x: number, y: number, width: number, height: number) {
      this.gl.scissor(x, y, width, height);
    }

    updateBegin() {
      var gl = this.gl;
      this.boundBuffer = null;
      this.indexBuffer = null;
      if (this.renderTarget) {
        // TODO
      } else {
        gl.bindFramebuffer(gl.FRAMEBUFFER, null);
      }
      for (let i = 0; i < this.textureUnits.length; i++) {
          this.textureUnits[i] = null;
      }
    }

    updateEnd() {
      if (this.renderTarget) {
        this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null);
      }
    }

    draw(primitive, numInstances: number) {
      var gl = this.gl;
      var shader = this.shader;

      if (numInstances > 1) {
        this.boundBuffer = null;
        this.attributesInvalidated = true;
      }

      if (this.attributesInvalidated) {
        var attribute: ShaderInput, element, vertexBuffer;
        var attributes = shader.attributes;
        for (let i = 0; i < attributes.length; i++) {
            attribute = attributes[i];
            // TODO
        }
        this.attributesInvalidated = false;
      }

      // TODO samplers
      // TODO uniforms

      if (primitive.indexed) {
        if (numInstances > 1) {
          this.capabilities.extInstancing
              .drawElementsInstancedANGLE(primitive.type,
                                          primitive.count,
                                          this.indexBuffer.format,
                                          primitive.base * 2,
                                          numInstances);
          this.boundBuffer = null;
          this.attributesInvalidated = true;
        } else {
          gl.drawElements(primitive.type, primitive.count, this.indexBuffer.format, primitive.base * this.indexBuffer.bytesPerIndex);
        }
      } else {
        if (numInstances > 1) {
          this.capabilities.extInstancing
              .drawArraysInstancedANGLE(primitive.type,
                                        primitive.base,
                                        primitive.count,
                                        numInstances);
          this.boundBuffer = null;
          this.attributesInvalidated = true;
        } else {
          gl.drawArrays(primitive.type,
                        primitive.base,
                        primitive.count);
        }
      }
    }

    clear(options?) {
      var defaultOptions = this.defaultClearOptions;
      options = options || defaultOptions;

      var flags:ClearFlags = (options.flags === undefined) ? defaultOptions.flags : options.flags;
      if (flags !== 0) {
          var gl = this.gl;

          // Set the clear color
          if (flags & ClearFlags.COLOR) {
              var color = (options.color === undefined) ? defaultOptions.color : options.color;
              this.setClearColor(color[0], color[1], color[2], color[3]);
          }

          if (flags & ClearFlags.DEPTH) {
              // Set the clear depth
              var depth = (options.depth === undefined) ? defaultOptions.depth : options.depth;
              this.setClearDepth(depth);
              if (!this.depthWrite) {
                  gl.depthMask(true);
              }
          }

          // Clear the frame buffer
          gl.clear(glClearFlag[flags]);

          if (flags & ClearFlags.DEPTH) {
              if (!this.depthWrite) {
                  gl.depthMask(false);
              }
          }
      }
    }

    setShader(shader: Shader) {
      if (this.shader !== shader) {
        this.shader = shader;
        this.gl.useProgram(shader.program);
        this.attributesInvalidated = true;
      }
    }

    private createContext(canvas: HTMLCanvasElement, options?): WebGLRenderingContext {
      var names = ["webgl", "experimental-webgl"];
        var context = null;
        for (var i = 0; i < names.length; i++) {
            try {
                context = canvas.getContext(names[i], options);
            } catch(e) {}
            if (context) {
                break;
            }
        }
        return context;
    }
  }
}
