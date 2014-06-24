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
  Shader shader;

  Pass([this.id]) {
    if (id == null) id = "Pass${_globalId++}";
  }

  // TODO FIXME
  void bind(gl.RenderingContext ctx) {
    ctx.useProgram(shader.program);
    enableState(ctx, gl.DEPTH_TEST, depthTest);
    enableState(ctx, gl.CULL_FACE, cullFaceEnable);
    enableState(ctx, gl.SAMPLE_ALPHA_TO_COVERAGE, true);
    enableState(ctx, gl.BLEND, blending);
    if (blending) {
      ctx.blendEquation(blendEquation);
      ctx.blendFunc(sfactor, dfactor);
    }
    ctx.depthMask(depthMask);
  }

  void enableState(gl.RenderingContext ctx, int cap, bool enable) {
    if (enable) {
      ctx.enable(cap);
    } else {
      ctx.disable(cap);
    }
  }

  void render(double time, Map options) {
    
  }

  dispose() {
    if (shader != null) shader.dispose();
  }
}






















