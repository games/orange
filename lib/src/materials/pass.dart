part of orange;



class Pass {
  static int _globalId = 0;

  String id;
  bool depthTest = true;
  bool depthMask = true;
  bool cullFaceEnable = true;
  bool blending = false;

  int blendEquation = gl.FUNC_ADD;
  int sfactor = gl.SRC_ALPHA;
  int dfactor = gl.ONE_MINUS_SRC_ALPHA;

  int alphaMode = 1;

  int modeRGB = gl.FUNC_ADD;
  int modeAlpha = gl.FUNC_ADD;
  int srcRGB = gl.SRC_ALPHA;
  int dstRGB = gl.ONE_MINUS_SRC_ALPHA;
  int srcAlpha = gl.ONE;
  int dstAlpha = gl.ONE;

  Shader shader;

  Pass([this.id]) {
    if (id == null) id = "Pass${_globalId++}";
  }

  void bind(GraphicsDevice device) {
    var ctx = device.ctx;
    ctx.useProgram(shader.program);
    device.enableState(gl.DEPTH_TEST, depthTest);
    device.cullingState = cullFaceEnable;
    device.enableState(gl.SAMPLE_ALPHA_TO_COVERAGE, true);
    device.enableState(gl.BLEND, blending);
    if (blending) {
      if (alphaMode == 0) {
        ctx.blendEquation(blendEquation);
        ctx.blendFunc(sfactor, dfactor);
      } else {
        ctx.blendEquationSeparate(modeRGB, modeAlpha);
        ctx.blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
      }
    }
    ctx.depthMask(depthMask);
  }

  dispose() {
    if (shader != null) shader.dispose();
  }
}




















