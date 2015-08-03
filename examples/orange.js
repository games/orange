var orange;
(function (orange) {
    (function (CullMode) {
        CullMode[CullMode["CULLFACE_NONE"] = 0] = "CULLFACE_NONE";
        CullMode[CullMode["CULLFACE_FRONT"] = 1] = "CULLFACE_FRONT";
        CullMode[CullMode["CULLFACE_BACK"] = 2] = "CULLFACE_BACK";
        CullMode[CullMode["CULLFACE_FRONTANDBACK"] = 3] = "CULLFACE_FRONTANDBACK";
    })(orange.CullMode || (orange.CullMode = {}));
    var CullMode = orange.CullMode;
    (function (ClearFlags) {
        ClearFlags[ClearFlags["COLOR"] = 1] = "COLOR";
        ClearFlags[ClearFlags["DEPTH"] = 2] = "DEPTH";
        ClearFlags[ClearFlags["STENCIL"] = 4] = "STENCIL";
    })(orange.ClearFlags || (orange.ClearFlags = {}));
    var ClearFlags = orange.ClearFlags;
    (function (UniformType) {
        UniformType[UniformType["BOOL"] = 0] = "BOOL";
        UniformType[UniformType["INT"] = 1] = "INT";
        UniformType[UniformType["FLOAT"] = 2] = "FLOAT";
        UniformType[UniformType["VEC2"] = 3] = "VEC2";
        UniformType[UniformType["VEC3"] = 4] = "VEC3";
        UniformType[UniformType["VEC4"] = 5] = "VEC4";
        UniformType[UniformType["IVEC2"] = 6] = "IVEC2";
        UniformType[UniformType["IVEC3"] = 7] = "IVEC3";
        UniformType[UniformType["IVEC4"] = 8] = "IVEC4";
        UniformType[UniformType["BVEC2"] = 9] = "BVEC2";
        UniformType[UniformType["BVEC3"] = 10] = "BVEC3";
        UniformType[UniformType["BVEC4"] = 11] = "BVEC4";
        UniformType[UniformType["MAT2"] = 12] = "MAT2";
        UniformType[UniformType["MAT3"] = 13] = "MAT3";
        UniformType[UniformType["MAT4"] = 14] = "MAT4";
        UniformType[UniformType["TEXTURE2D"] = 15] = "TEXTURE2D";
        UniformType[UniformType["TEXTURECUBE"] = 16] = "TEXTURECUBE";
    })(orange.UniformType || (orange.UniformType = {}));
    var UniformType = orange.UniformType;
    orange.SEMANTIC_POSITION = "POSITION";
    orange.SEMANTIC_NORMAL = "NORMAL";
    orange.SEMANTIC_TANGENT = "TANGENT";
    orange.SEMANTIC_BLENDWEIGHT = "BLENDWEIGHT";
    orange.SEMANTIC_BLENDINDICES = "BLENDINDICES";
    orange.SEMANTIC_COLOR = "COLOR";
    orange.SEMANTIC_TEXCOORD0 = "TEXCOORD0";
    orange.SEMANTIC_TEXCOORD1 = "TEXCOORD1";
    orange.SEMANTIC_TEXCOORD2 = "TEXCOORD2";
    orange.SEMANTIC_TEXCOORD3 = "TEXCOORD3";
    orange.SEMANTIC_TEXCOORD4 = "TEXCOORD4";
    orange.SEMANTIC_TEXCOORD5 = "TEXCOORD5";
    orange.SEMANTIC_TEXCOORD6 = "TEXCOORD6";
    orange.SEMANTIC_TEXCOORD7 = "TEXCOORD7";
    orange.SEMANTIC_ATTR0 = "ATTR0";
    orange.SEMANTIC_ATTR1 = "ATTR1";
    orange.SEMANTIC_ATTR2 = "ATTR2";
    orange.SEMANTIC_ATTR3 = "ATTR3";
    orange.SEMANTIC_ATTR4 = "ATTR4";
    orange.SEMANTIC_ATTR5 = "ATTR5";
    orange.SEMANTIC_ATTR6 = "ATTR6";
    orange.SEMANTIC_ATTR7 = "ATTR7";
    orange.SEMANTIC_ATTR8 = "ATTR8";
    orange.SEMANTIC_ATTR9 = "ATTR9";
    orange.SEMANTIC_ATTR10 = "ATTR10";
    orange.SEMANTIC_ATTR11 = "ATTR11";
    orange.SEMANTIC_ATTR12 = "ATTR12";
    orange.SEMANTIC_ATTR13 = "ATTR13";
    orange.SEMANTIC_ATTR14 = "ATTR14";
    orange.SEMANTIC_ATTR15 = "ATTR15";
})(orange || (orange = {}));
var orange;
(function (orange) {
    var DeviceCapabilities = (function () {
        function DeviceCapabilities(gl) {
            this.precision = "highp";
            var vertexShaderPrecisionHighpFloat = gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.HIGH_FLOAT);
            var vertexShaderPrecisionMediumpFloat = gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.MEDIUM_FLOAT);
            var vertexShaderPrecisionLowpFloat = gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.LOW_FLOAT);
            var fragmentShaderPrecisionHighpFloat = gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.HIGH_FLOAT);
            var fragmentShaderPrecisionMediumpFloat = gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.MEDIUM_FLOAT);
            var fragmentShaderPrecisionLowpFloat = gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.LOW_FLOAT);
            var vertexShaderPrecisionHighpInt = gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.HIGH_INT);
            var vertexShaderPrecisionMediumpInt = gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.MEDIUM_INT);
            var vertexShaderPrecisionLowpInt = gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.LOW_INT);
            var fragmentShaderPrecisionHighpInt = gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.HIGH_INT);
            var fragmentShaderPrecisionMediumpInt = gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.MEDIUM_INT);
            var fragmentShaderPrecisionLowpInt = gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.LOW_INT);
            var highpAvailable = vertexShaderPrecisionHighpFloat.precision > 0 && fragmentShaderPrecisionHighpFloat.precision > 0;
            var mediumpAvailable = vertexShaderPrecisionMediumpFloat.precision > 0 && fragmentShaderPrecisionMediumpFloat.precision > 0;
            if (!highpAvailable) {
                if (mediumpAvailable) {
                    this.precision = "mediump";
                    console.warn("WARNING: highp not supported, using mediump");
                }
                else {
                    this.precision = "lowp";
                    console.warn("WARNING: highp and mediump not supported, using lowp");
                }
            }
            // Initialize extensions
            this.extTextureFloat = gl.getExtension("OES_texture_float");
            this.extTextureFloatLinear = gl.getExtension("OES_texture_float_linear");
            this.extTextureHalfFloat = gl.getExtension("OES_texture_half_float");
            this.extUintElement = gl.getExtension("OES_element_index_uint");
            this.maxVertexTextures = gl.getParameter(gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
            this.supportsBoneTextures = this.extTextureFloat && this.maxVertexTextures > 0;
            // Test if we can render to floating-point RGBA texture
            this.extTextureFloatRenderable = !!this.extTextureFloat;
            if (this.extTextureFloat) {
                var __texture = gl.createTexture();
                gl.bindTexture(gl.TEXTURE_2D, __texture);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
                var __width = 2;
                var __height = 2;
                gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, __width, __height, 0, gl.RGBA, gl.FLOAT, null);
                // Try to use this texture as a render target.
                var __fbo = gl.createFramebuffer();
                gl.bindFramebuffer(gl.FRAMEBUFFER, __fbo);
                gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, __texture, 0);
                gl.bindTexture(gl.TEXTURE_2D, null);
                // It is legal for a WebGL implementation exposing the OES_texture_float extension to
                // support floating-point textures but not as attachments to framebuffer objects.
                if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE) {
                    this.extTextureFloatRenderable = false;
                }
            }
            this.extTextureLod = gl.getExtension('EXT_shader_texture_lod');
            this.fragmentUniformsCount = gl.getParameter(gl.MAX_FRAGMENT_UNIFORM_VECTORS);
            this.samplerCount = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS);
            this.useTexCubeLod = this.extTextureLod && this.samplerCount < 16;
            this.extDepthTexture = null; //gl.getExtension("WEBKIT_WEBGL_depth_texture");
            this.extStandardDerivatives = gl.getExtension("OES_standard_derivatives");
            if (this.extStandardDerivatives) {
                gl.hint(this.extStandardDerivatives.FRAGMENT_SHADER_DERIVATIVE_HINT_OES, gl.NICEST);
            }
            this.extTextureFilterAnisotropic = gl.getExtension('EXT_texture_filter_anisotropic');
            if (!this.extTextureFilterAnisotropic) {
                this.extTextureFilterAnisotropic = gl.getExtension('WEBKIT_EXT_texture_filter_anisotropic');
            }
            this.extCompressedTextureS3TC = gl.getExtension('WEBGL_compressed_texture_s3tc');
            if (!this.extCompressedTextureS3TC) {
                this.extCompressedTextureS3TC = gl.getExtension('WEBKIT_WEBGL_compressed_texture_s3tc');
            }
            if (this.extCompressedTextureS3TC) {
                if (this.isIE()) {
                    // IE 11 can't use mip maps with S3TC
                    this.extCompressedTextureS3TC = false;
                }
            }
            if (this.extCompressedTextureS3TC) {
                var formats = gl.getParameter(gl.COMPRESSED_TEXTURE_FORMATS);
                for (var i = 0; i < formats.length; i++) {
                    switch (formats[i]) {
                        case this.extCompressedTextureS3TC.COMPRESSED_RGB_S3TC_DXT1_EXT:
                            break;
                        case this.extCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT1_EXT:
                            break;
                        case this.extCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT3_EXT:
                            break;
                        case this.extCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT:
                            break;
                        default:
                            break;
                    }
                }
            }
            this.extInstancing = gl.getExtension("ANGLE_instanced_arrays");
            this.extCompressedTextureETC1 = gl.getExtension('WEBGL_compressed_texture_etc1');
            this.extDrawBuffers = gl.getExtension('EXT_draw_buffers');
            this.maxDrawBuffers = this.extDrawBuffers ? gl.getParameter(this.extDrawBuffers.MAX_DRAW_BUFFERS_EXT) : 1;
            this.maxColorAttachments = this.extDrawBuffers ? gl.getParameter(this.extDrawBuffers.MAX_COLOR_ATTACHMENTS_EXT) : 1;
        }
        DeviceCapabilities.prototype.isIE = function () {
            var ua = window.navigator.userAgent;
            var msie = ua.indexOf("MSIE ");
            var trident = navigator.userAgent.match(/Trident.*rv\:11\./);
            return (msie > 0 || !!trident);
        };
        return DeviceCapabilities;
    })();
    orange.DeviceCapabilities = DeviceCapabilities;
})(orange || (orange = {}));
var orange;
(function (orange) {
    var Engine = (function () {
        function Engine() {
        }
        return Engine;
    })();
    orange.Engine = Engine;
})(orange || (orange = {}));
var orange;
(function (orange) {
    var GraphicsDevice = (function () {
        function GraphicsDevice(canvas) {
            this.canvas = canvas;
            var gl = this.createContext(canvas);
            this.gl = gl;
            this.capabilities = new orange.DeviceCapabilities(gl);
            this.defaultClearOptions = {
                color: [0, 0, 0, 1],
                depth: 1,
                flags: orange.ClearFlags.COLOR | orange.ClearFlags.DEPTH
            };
            this.textureUnits = new Array(16);
            this.setBlending(false);
            this.setBlendFunction(gl.ONE, gl.ZERO);
            this.setBlendEquation(gl.FUNC_ADD);
            this.setColorWrite(true, true, true, true);
            this.setCullMode(orange.CullMode.CULLFACE_BACK);
            this.setDepthTest(true);
            this.setDepthWrite(true);
            this.setClearDepth(1);
            this.setClearColor(0, 0, 0, 0);
            this.gl.enable(gl.SCISSOR_TEST);
        }
        GraphicsDevice.prototype.setBlending = function (blending) {
            if (this.blending !== blending) {
                var gl = this.gl;
                if (blending) {
                    gl.enable(gl.BLEND);
                }
                else {
                    gl.disable(gl.BLEND);
                }
                this.blending = blending;
            }
        };
        GraphicsDevice.prototype.setBlendFunction = function (blendSrc, blendDst) {
            if (this.blendSrc !== blendSrc ||
                this.blendDst !== blendDst) {
                this.gl.blendFunc(blendSrc, blendDst);
                this.blendSrc = blendSrc;
                this.blendDst = blendDst;
            }
        };
        GraphicsDevice.prototype.setBlendEquation = function (blendEquation) {
            if (this.blendEquation !== blendEquation) {
                this.gl.blendEquation(blendEquation);
                this.blendEquation = blendEquation;
            }
        };
        GraphicsDevice.prototype.setCullMode = function (cullMode) {
            if (this.cullMode !== cullMode) {
                switch (cullMode) {
                    case orange.CullMode.CULLFACE_NONE:
                        this.gl.disable(this.gl.CULL_FACE);
                        break;
                    case orange.CullMode.CULLFACE_FRONT:
                        this.gl.enable(this.gl.CULL_FACE);
                        this.gl.cullFace(this.gl.FRONT);
                        break;
                    case orange.CullMode.CULLFACE_BACK:
                        this.gl.enable(this.gl.CULL_FACE);
                        this.gl.cullFace(this.gl.BACK);
                        break;
                    case orange.CullMode.CULLFACE_FRONTANDBACK:
                        this.gl.enable(this.gl.CULL_FACE);
                        this.gl.cullFace(this.gl.FRONT_AND_BACK);
                        break;
                }
                this.cullMode = cullMode;
            }
        };
        GraphicsDevice.prototype.setColorWrite = function (writeRed, writeGreen, writeBlue, writeAlpha) {
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
        };
        GraphicsDevice.prototype.setDepthTest = function (depthTest) {
            if (this.depthTest !== depthTest) {
                var gl = this.gl;
                if (depthTest) {
                    gl.enable(gl.DEPTH_TEST);
                }
                else {
                    gl.disable(gl.DEPTH_TEST);
                }
                this.depthTest = depthTest;
            }
        };
        GraphicsDevice.prototype.setDepthWrite = function (writeDepth) {
            if (this.depthWrite !== writeDepth) {
                this.gl.depthMask(writeDepth);
                this.depthWrite = writeDepth;
            }
        };
        GraphicsDevice.prototype.setClearDepth = function (depth) {
            if (this.clearDepth !== depth) {
                this.gl.clearDepth(depth);
                this.clearDepth = depth;
            }
        };
        GraphicsDevice.prototype.setClearColor = function (r, g, b, a) {
            if ((r !== this.clearRed) || (g !== this.clearGreen) || (b !== this.clearBlue) || (a !== this.clearAlpha)) {
                this.gl.clearColor(r, g, b, a);
                this.clearRed = r;
                this.clearGreen = g;
                this.clearBlue = b;
                this.clearAlpha = a;
            }
        };
        GraphicsDevice.prototype.setViewport = function (x, y, width, height) {
            this.gl.viewport(x, y, width, height);
        };
        GraphicsDevice.prototype.setScissor = function (x, y, width, height) {
            this.gl.scissor(x, y, width, height);
        };
        GraphicsDevice.prototype.updateBegin = function () {
            var gl = this.gl;
            this.boundBuffer = null;
            this.indexBuffer = null;
            if (this.renderTarget) {
            }
            else {
                gl.bindFramebuffer(gl.FRAMEBUFFER, null);
            }
            for (var i = 0; i < this.textureUnits.length; i++) {
                this.textureUnits[i] = null;
            }
        };
        GraphicsDevice.prototype.updateEnd = function () {
            if (this.renderTarget) {
                this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null);
            }
        };
        GraphicsDevice.prototype.draw = function (primitive, numInstances) {
            var gl = this.gl;
            var shader = this.shader;
            if (numInstances > 1) {
                this.boundBuffer = null;
                this.attributesInvalidated = true;
            }
            if (this.attributesInvalidated) {
                var attribute, element, vertexBuffer;
                var attributes = shader.attributes;
                for (var i = 0; i < attributes.length; i++) {
                    attribute = attributes[i];
                }
                this.attributesInvalidated = false;
            }
            // TODO samplers
            // TODO uniforms
            if (primitive.indexed) {
                if (numInstances > 1) {
                    this.capabilities.extInstancing
                        .drawElementsInstancedANGLE(primitive.type, primitive.count, this.indexBuffer.format, primitive.base * 2, numInstances);
                    this.boundBuffer = null;
                    this.attributesInvalidated = true;
                }
                else {
                    gl.drawElements(primitive.type, primitive.count, this.indexBuffer.format, primitive.base * this.indexBuffer.bytesPerIndex);
                }
            }
            else {
                if (numInstances > 1) {
                    this.capabilities.extInstancing
                        .drawArraysInstancedANGLE(primitive.type, primitive.base, primitive.count, numInstances);
                    this.boundBuffer = null;
                    this.attributesInvalidated = true;
                }
                else {
                    gl.drawArrays(primitive.type, primitive.base, primitive.count);
                }
            }
        };
        GraphicsDevice.prototype.clear = function (options) {
            var defaultOptions = this.defaultClearOptions;
            options = options || defaultOptions;
            var flags = (options.flags === undefined) ? defaultOptions.flags : options.flags;
            if (flags !== 0) {
                var gl = this.gl;
                // Set the clear color
                if (flags & orange.ClearFlags.COLOR) {
                    var color = (options.color === undefined) ? defaultOptions.color : options.color;
                    this.setClearColor(color[0], color[1], color[2], color[3]);
                }
                if (flags & orange.ClearFlags.DEPTH) {
                    // Set the clear depth
                    var depth = (options.depth === undefined) ? defaultOptions.depth : options.depth;
                    this.setClearDepth(depth);
                    if (!this.depthWrite) {
                        gl.depthMask(true);
                    }
                }
                // Clear the frame buffer
                gl.clear(this.glClearFlag[flags]);
                if (flags & orange.ClearFlags.DEPTH) {
                    if (!this.depthWrite) {
                        gl.depthMask(false);
                    }
                }
            }
        };
        GraphicsDevice.prototype.setShader = function (shader) {
            if (this.shader !== shader) {
                this.shader = shader;
                this.gl.useProgram(shader.program);
                this.attributesInvalidated = true;
            }
        };
        GraphicsDevice.prototype.createContext = function (canvas, options) {
            var names = ["webgl", "experimental-webgl"];
            var context = null;
            for (var i = 0; i < names.length; i++) {
                try {
                    context = canvas.getContext(names[i], options);
                }
                catch (e) { }
                if (context) {
                    break;
                }
            }
            return context;
        };
        return GraphicsDevice;
    })();
    orange.GraphicsDevice = GraphicsDevice;
})(orange || (orange = {}));
var orange;
(function (orange) {
    function addLineNumbers(src) {
        var chunks = src.split("\n");
        for (var i = 0; i < chunks.length; i++) {
            chunks[i] = (i + 1) + ":\t" + chunks[i];
        }
        return chunks.join("\n");
    }
    function createShader(gl, type, src) {
        var shader = gl.createShader(type);
        gl.shaderSource(shader, src);
        gl.compileShader(shader);
        var ok = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
        if (!ok) {
            var error = gl.getShaderInfoLog(shader);
            var typeName = (type === gl.VERTEX_SHADER) ? "vertex" : "fragment";
            console.error("Failed to compile " + typeName + " shader:\n\n" + addLineNumbers(src) + "\n\n" + error);
        }
        return shader;
    }
    function createProgram(gl, vertexShader, fragmentShader) {
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
    var ShaderDefinition = (function () {
        function ShaderDefinition() {
        }
        return ShaderDefinition;
    })();
    orange.ShaderDefinition = ShaderDefinition;
    var ShaderInput = (function () {
        function ShaderInput(graphicsDevice, name, type, location) {
            this.graphicsDevice = graphicsDevice;
            this.name = name;
            this.type = type;
            this.location = location;
        }
        return ShaderInput;
    })();
    orange.ShaderInput = ShaderInput;
    var Shader = (function () {
        function Shader(graphicsDevice, definition) {
            this.graphicsDevice = graphicsDevice;
            this.definition = definition;
            var gl = graphicsDevice.gl;
            var vertexShader = createShader(gl, gl.VERTEX_SHADER, definition.vshader);
            var fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, definition.fshader);
            this.program = createProgram(gl, vertexShader, fragmentShader);
            gl.deleteShader(vertexShader);
            gl.deleteShader(fragmentShader);
            this.attributes = new Array();
            this.uniforms = new Array();
            this.samplers = new Array();
            var i = 0;
            var info;
            var location;
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
            while (i < numUniforms) {
                info = gl.getActiveUniform(this.program, i++);
                location = gl.getUniformLocation(this.program, info.name);
                if ((info.type === gl.SAMPLER_2D) || (info.type === gl.SAMPLER_CUBE)) {
                    this.samplers.push(new ShaderInput(graphicsDevice, info.name, info.type, location));
                }
                else {
                    this.uniforms.push(new ShaderInput(graphicsDevice, info.name, info.type, location));
                }
            }
        }
        Shader.prototype.destroy = function () {
            this.graphicsDevice.gl.deleteProgram(this.program);
        };
        return Shader;
    })();
    orange.Shader = Shader;
})(orange || (orange = {}));
var orange;
(function (orange) {
    var Texture = (function () {
        function Texture() {
        }
        return Texture;
    })();
    orange.Texture = Texture;
})(orange || (orange = {}));
