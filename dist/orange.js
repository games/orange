var orange;!function(e){!function(e){e[e.CULLFACE_NONE=0]="CULLFACE_NONE",e[e.CULLFACE_FRONT=1]="CULLFACE_FRONT",e[e.CULLFACE_BACK=2]="CULLFACE_BACK",e[e.CULLFACE_FRONTANDBACK=3]="CULLFACE_FRONTANDBACK"}(e.CullMode||(e.CullMode={}));e.CullMode;!function(e){e[e.COLOR=1]="COLOR",e[e.DEPTH=2]="DEPTH",e[e.STENCIL=4]="STENCIL"}(e.ClearFlags||(e.ClearFlags={}));e.ClearFlags;!function(e){e[e.BOOL=0]="BOOL",e[e.INT=1]="INT",e[e.FLOAT=2]="FLOAT",e[e.VEC2=3]="VEC2",e[e.VEC3=4]="VEC3",e[e.VEC4=5]="VEC4",e[e.IVEC2=6]="IVEC2",e[e.IVEC3=7]="IVEC3",e[e.IVEC4=8]="IVEC4",e[e.BVEC2=9]="BVEC2",e[e.BVEC3=10]="BVEC3",e[e.BVEC4=11]="BVEC4",e[e.MAT2=12]="MAT2",e[e.MAT3=13]="MAT3",e[e.MAT4=14]="MAT4",e[e.TEXTURE2D=15]="TEXTURE2D",e[e.TEXTURECUBE=16]="TEXTURECUBE"}(e.UniformType||(e.UniformType={}));e.UniformType;e.SEMANTIC_POSITION="POSITION",e.SEMANTIC_NORMAL="NORMAL",e.SEMANTIC_TANGENT="TANGENT",e.SEMANTIC_BLENDWEIGHT="BLENDWEIGHT",e.SEMANTIC_BLENDINDICES="BLENDINDICES",e.SEMANTIC_COLOR="COLOR",e.SEMANTIC_TEXCOORD0="TEXCOORD0",e.SEMANTIC_TEXCOORD1="TEXCOORD1",e.SEMANTIC_TEXCOORD2="TEXCOORD2",e.SEMANTIC_TEXCOORD3="TEXCOORD3",e.SEMANTIC_TEXCOORD4="TEXCOORD4",e.SEMANTIC_TEXCOORD5="TEXCOORD5",e.SEMANTIC_TEXCOORD6="TEXCOORD6",e.SEMANTIC_TEXCOORD7="TEXCOORD7",e.SEMANTIC_ATTR0="ATTR0",e.SEMANTIC_ATTR1="ATTR1",e.SEMANTIC_ATTR2="ATTR2",e.SEMANTIC_ATTR3="ATTR3",e.SEMANTIC_ATTR4="ATTR4",e.SEMANTIC_ATTR5="ATTR5",e.SEMANTIC_ATTR6="ATTR6",e.SEMANTIC_ATTR7="ATTR7",e.SEMANTIC_ATTR8="ATTR8",e.SEMANTIC_ATTR9="ATTR9",e.SEMANTIC_ATTR10="ATTR10",e.SEMANTIC_ATTR11="ATTR11",e.SEMANTIC_ATTR12="ATTR12",e.SEMANTIC_ATTR13="ATTR13",e.SEMANTIC_ATTR14="ATTR14",e.SEMANTIC_ATTR15="ATTR15"}(orange||(orange={}));var orange;!function(e){var t=function(){function e(e){this.precision="highp";var t=e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.HIGH_FLOAT),r=e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.MEDIUM_FLOAT),i=(e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.LOW_FLOAT),e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.HIGH_FLOAT)),s=e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.MEDIUM_FLOAT),a=(e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.LOW_FLOAT),e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.HIGH_INT),e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.MEDIUM_INT),e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.LOW_INT),e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.HIGH_INT),e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.MEDIUM_INT),e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.LOW_INT),t.precision>0&&i.precision>0),n=r.precision>0&&s.precision>0;if(a||(n?(this.precision="mediump",console.warn("WARNING: highp not supported, using mediump")):(this.precision="lowp",console.warn("WARNING: highp and mediump not supported, using lowp"))),this.extTextureFloat=e.getExtension("OES_texture_float"),this.extTextureFloatLinear=e.getExtension("OES_texture_float_linear"),this.extTextureHalfFloat=e.getExtension("OES_texture_half_float"),this.extUintElement=e.getExtension("OES_element_index_uint"),this.maxVertexTextures=e.getParameter(e.MAX_VERTEX_TEXTURE_IMAGE_UNITS),this.supportsBoneTextures=this.extTextureFloat&&this.maxVertexTextures>0,this.extTextureFloatRenderable=!!this.extTextureFloat,this.extTextureFloat){var o=e.createTexture();e.bindTexture(e.TEXTURE_2D,o),e.texParameteri(e.TEXTURE_2D,e.TEXTURE_MIN_FILTER,e.NEAREST),e.texParameteri(e.TEXTURE_2D,e.TEXTURE_MAG_FILTER,e.NEAREST),e.texParameteri(e.TEXTURE_2D,e.TEXTURE_WRAP_S,e.CLAMP_TO_EDGE),e.texParameteri(e.TEXTURE_2D,e.TEXTURE_WRAP_T,e.CLAMP_TO_EDGE);var T=2,E=2;e.texImage2D(e.TEXTURE_2D,0,e.RGBA,T,E,0,e.RGBA,e.FLOAT,null);var h=e.createFramebuffer();e.bindFramebuffer(e.FRAMEBUFFER,h),e.framebufferTexture2D(e.FRAMEBUFFER,e.COLOR_ATTACHMENT0,e.TEXTURE_2D,o,0),e.bindTexture(e.TEXTURE_2D,null),e.checkFramebufferStatus(e.FRAMEBUFFER)!=e.FRAMEBUFFER_COMPLETE&&(this.extTextureFloatRenderable=!1)}if(this.extTextureLod=e.getExtension("EXT_shader_texture_lod"),this.fragmentUniformsCount=e.getParameter(e.MAX_FRAGMENT_UNIFORM_VECTORS),this.samplerCount=e.getParameter(e.MAX_TEXTURE_IMAGE_UNITS),this.useTexCubeLod=this.extTextureLod&&this.samplerCount<16,this.extDepthTexture=null,this.extStandardDerivatives=e.getExtension("OES_standard_derivatives"),this.extStandardDerivatives&&e.hint(this.extStandardDerivatives.FRAGMENT_SHADER_DERIVATIVE_HINT_OES,e.NICEST),this.extTextureFilterAnisotropic=e.getExtension("EXT_texture_filter_anisotropic"),this.extTextureFilterAnisotropic||(this.extTextureFilterAnisotropic=e.getExtension("WEBKIT_EXT_texture_filter_anisotropic")),this.extCompressedTextureS3TC=e.getExtension("WEBGL_compressed_texture_s3tc"),this.extCompressedTextureS3TC||(this.extCompressedTextureS3TC=e.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc")),this.extCompressedTextureS3TC&&this.isIE()&&(this.extCompressedTextureS3TC=!1),this.extCompressedTextureS3TC)for(var l=e.getParameter(e.COMPRESSED_TEXTURE_FORMATS),u=0;u<l.length;u++)switch(l[u]){case this.extCompressedTextureS3TC.COMPRESSED_RGB_S3TC_DXT1_EXT:break;case this.extCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT1_EXT:break;case this.extCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT3_EXT:break;case this.extCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT:}this.extInstancing=e.getExtension("ANGLE_instanced_arrays"),this.extCompressedTextureETC1=e.getExtension("WEBGL_compressed_texture_etc1"),this.extDrawBuffers=e.getExtension("EXT_draw_buffers"),this.maxDrawBuffers=this.extDrawBuffers?e.getParameter(this.extDrawBuffers.MAX_DRAW_BUFFERS_EXT):1,this.maxColorAttachments=this.extDrawBuffers?e.getParameter(this.extDrawBuffers.MAX_COLOR_ATTACHMENTS_EXT):1}return e.prototype.isIE=function(){var e=window.navigator.userAgent,t=e.indexOf("MSIE "),r=navigator.userAgent.match(/Trident.*rv\:11\./);return t>0||!!r},e}();e.DeviceCapabilities=t}(orange||(orange={}));var orange;!function(e){var t=function(){function e(){}return e}();e.Engine=t}(orange||(orange={}));var orange;!function(e){var t=function(){function t(t){this.canvas=t;var r=this.createContext(t);this.gl=r,this.capabilities=new e.DeviceCapabilities(r),this.defaultClearOptions={color:[0,0,0,1],depth:1,flags:e.ClearFlags.COLOR|e.ClearFlags.DEPTH},this.textureUnits=new Array(16),this.setBlending(!1),this.setBlendFunction(r.ONE,r.ZERO),this.setBlendEquation(r.FUNC_ADD),this.setColorWrite(!0,!0,!0,!0),this.setCullMode(e.CullMode.CULLFACE_BACK),this.setDepthTest(!0),this.setDepthWrite(!0),this.setClearDepth(1),this.setClearColor(0,0,0,0),this.gl.enable(r.SCISSOR_TEST)}return t.prototype.setBlending=function(e){if(this.blending!==e){var t=this.gl;e?t.enable(t.BLEND):t.disable(t.BLEND),this.blending=e}},t.prototype.setBlendFunction=function(e,t){(this.blendSrc!==e||this.blendDst!==t)&&(this.gl.blendFunc(e,t),this.blendSrc=e,this.blendDst=t)},t.prototype.setBlendEquation=function(e){this.blendEquation!==e&&(this.gl.blendEquation(e),this.blendEquation=e)},t.prototype.setCullMode=function(t){if(this.cullMode!==t){switch(t){case e.CullMode.CULLFACE_NONE:this.gl.disable(this.gl.CULL_FACE);break;case e.CullMode.CULLFACE_FRONT:this.gl.enable(this.gl.CULL_FACE),this.gl.cullFace(this.gl.FRONT);break;case e.CullMode.CULLFACE_BACK:this.gl.enable(this.gl.CULL_FACE),this.gl.cullFace(this.gl.BACK);break;case e.CullMode.CULLFACE_FRONTANDBACK:this.gl.enable(this.gl.CULL_FACE),this.gl.cullFace(this.gl.FRONT_AND_BACK)}this.cullMode=t}},t.prototype.setColorWrite=function(e,t,r,i){(this.writeRed!==e||this.writeGreen!==t||this.writeBlue!==r||this.writeAlpha!==i)&&(this.gl.colorMask(e,t,r,i),this.writeRed=e,this.writeGreen=t,this.writeBlue=r,this.writeAlpha=i)},t.prototype.setDepthTest=function(e){if(this.depthTest!==e){var t=this.gl;e?t.enable(t.DEPTH_TEST):t.disable(t.DEPTH_TEST),this.depthTest=e}},t.prototype.setDepthWrite=function(e){this.depthWrite!==e&&(this.gl.depthMask(e),this.depthWrite=e)},t.prototype.setClearDepth=function(e){this.clearDepth!==e&&(this.gl.clearDepth(e),this.clearDepth=e)},t.prototype.setClearColor=function(e,t,r,i){(e!==this.clearRed||t!==this.clearGreen||r!==this.clearBlue||i!==this.clearAlpha)&&(this.gl.clearColor(e,t,r,i),this.clearRed=e,this.clearGreen=t,this.clearBlue=r,this.clearAlpha=i)},t.prototype.setViewport=function(e,t,r,i){this.gl.viewport(e,t,r,i)},t.prototype.setScissor=function(e,t,r,i){this.gl.scissor(e,t,r,i)},t.prototype.updateBegin=function(){var e=this.gl;this.boundBuffer=null,this.indexBuffer=null,this.renderTarget||e.bindFramebuffer(e.FRAMEBUFFER,null);for(var t=0;t<this.textureUnits.length;t++)this.textureUnits[t]=null},t.prototype.updateEnd=function(){this.renderTarget&&this.gl.bindFramebuffer(this.gl.FRAMEBUFFER,null)},t.prototype.draw=function(e,t){var r=this.gl,i=this.shader;if(t>1&&(this.boundBuffer=null,this.attributesInvalidated=!0),this.attributesInvalidated){for(var s,a=i.attributes,n=0;n<a.length;n++)s=a[n];this.attributesInvalidated=!1}e.indexed?t>1?(this.capabilities.extInstancing.drawElementsInstancedANGLE(e.type,e.count,this.indexBuffer.format,2*e.base,t),this.boundBuffer=null,this.attributesInvalidated=!0):r.drawElements(e.type,e.count,this.indexBuffer.format,e.base*this.indexBuffer.bytesPerIndex):t>1?(this.capabilities.extInstancing.drawArraysInstancedANGLE(e.type,e.base,e.count,t),this.boundBuffer=null,this.attributesInvalidated=!0):r.drawArrays(e.type,e.base,e.count)},t.prototype.clear=function(t){var r=this.defaultClearOptions;t=t||r;var i=void 0===t.flags?r.flags:t.flags;if(0!==i){var s=this.gl;if(i&e.ClearFlags.COLOR){var a=void 0===t.color?r.color:t.color;this.setClearColor(a[0],a[1],a[2],a[3])}if(i&e.ClearFlags.DEPTH){var n=void 0===t.depth?r.depth:t.depth;this.setClearDepth(n),this.depthWrite||s.depthMask(!0)}s.clear(this.glClearFlag[i]),i&e.ClearFlags.DEPTH&&(this.depthWrite||s.depthMask(!1))}},t.prototype.setShader=function(e){this.shader!==e&&(this.shader=e,this.gl.useProgram(e.program),this.attributesInvalidated=!0)},t.prototype.createContext=function(e,t){for(var r=["webgl","experimental-webgl"],i=null,s=0;s<r.length;s++){try{i=e.getContext(r[s],t)}catch(a){}if(i)break}return i},t}();e.GraphicsDevice=t}(orange||(orange={}));var orange;!function(e){function t(e){for(var t=e.split("\n"),r=0;r<t.length;r++)t[r]=r+1+":	"+t[r];return t.join("\n")}function r(e,r,i){var s=e.createShader(r);e.shaderSource(s,i),e.compileShader(s);var a=e.getShaderParameter(s,e.COMPILE_STATUS);if(!a){var n=e.getShaderInfoLog(s),o=r===e.VERTEX_SHADER?"vertex":"fragment";console.error("Failed to compile "+o+" shader:\n\n"+t(i)+"\n\n"+n)}return s}function i(e,t,r){var i=e.createProgram();e.attachShader(i,t),e.attachShader(i,r),e.linkProgram(i);var s=e.getProgramParameter(i,e.LINK_STATUS);if(!s){var a=e.getProgramInfoLog(i);console.error("Failed to link shader program. Error: "+a)}return i}var s=function(){function e(){}return e}();e.ShaderDefinition=s;var a=function(){function e(e,t,r,i){this.graphicsDevice=e,this.name=t,this.type=r,this.location=i}return e}();e.ShaderInput=a;var n=function(){function e(e,t){this.graphicsDevice=e,this.definition=t;var s=e.gl,n=r(s,s.VERTEX_SHADER,t.vshader),o=r(s,s.FRAGMENT_SHADER,t.fshader);this.program=i(s,n,o),s.deleteShader(n),s.deleteShader(o),this.attributes=new Array,this.uniforms=new Array,this.samplers=new Array;for(var T,E,h=0,l=s.getProgramParameter(this.program,s.ACTIVE_ATTRIBUTES);l>h;){T=s.getActiveAttrib(this.program,h++),E=s.getAttribLocation(this.program,T.name),void 0===t.atributes[T.name]&&console.error('Vertex shader attribute "'+T.name+'" is not mapped to a semantic in shader definition.');var u=new a(e,t.atributes[T.name],T.type,E);this.attributes.push(u)}h=0;for(var C=s.getProgramParameter(this.program,s.ACTIVE_UNIFORMS);C>h;)T=s.getActiveUniform(this.program,h++),E=s.getUniformLocation(this.program,T.name),T.type===s.SAMPLER_2D||T.type===s.SAMPLER_CUBE?this.samplers.push(new a(e,T.name,T.type,E)):this.uniforms.push(new a(e,T.name,T.type,E))}return e.prototype.destroy=function(){this.graphicsDevice.gl.deleteProgram(this.program)},e}();e.Shader=n}(orange||(orange={}));var orange;!function(e){var t=function(){function e(){}return e}();e.Texture=t}(orange||(orange={}));