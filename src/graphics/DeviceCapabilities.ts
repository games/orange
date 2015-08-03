module orange {

  export class DeviceCapabilities {

    precision = "highp";
    extTextureFloat;
    extTextureFloatLinear;
    extTextureHalfFloat;
    maxVertexTextures;
    supportsBoneTextures;
    extUintElement;
    extTextureFloatRenderable;
    extTextureLod;
    fragmentUniformsCount;
    samplerCount;
    useTexCubeLod;
    extDepthTexture;
    extStandardDerivatives;
    extTextureFilterAnisotropic;
    extCompressedTextureS3TC;
    extInstancing;
    extCompressedTextureETC1;
    extDrawBuffers;
    maxDrawBuffers;
    maxColorAttachments;

    constructor(gl: WebGLRenderingContext) {

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
        } else {
            this.precision = "lowp";
            console.warn( "WARNING: highp and mediump not supported, using lowp" );
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

    private isIE() {
      var ua = window.navigator.userAgent;
      var msie = ua.indexOf("MSIE ");
      var trident = navigator.userAgent.match(/Trident.*rv\:11\./);

      return (msie > 0 || !!trident);
    }
  }
}
