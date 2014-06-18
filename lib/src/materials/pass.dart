part of orange;



class Pass {
  bool depthTest = true;
  bool depthMask = true;
  bool cullFaceEnable = true;
  bool blending = false;
  int blendEquation = gl.FUNC_ADD;
  int sfactor = gl.SRC_ALPHA;
  int dfactor = gl.ONE_MINUS_SRC_ALPHA;
  Shader shader;

  @deprecated
  prepare(gl.RenderingContext ctx) {
    ctx.useProgram(shader.program);
    setState(ctx, gl.BLEND, blending);
    setState(ctx, gl.DEPTH_TEST, depthTest);
    setState(ctx, gl.CULL_FACE, cullFaceEnable);
    setState(ctx, gl.SAMPLE_ALPHA_TO_COVERAGE, true);
    ctx.depthMask(depthMask);
  }

  bind(gl.RenderingContext ctx) {
    ctx.useProgram(shader.program);
    setState(ctx, gl.DEPTH_TEST, depthTest);
    setState(ctx, gl.CULL_FACE, cullFaceEnable);
    setState(ctx, gl.SAMPLE_ALPHA_TO_COVERAGE, true);
//    ctx.depthMask(depthMask);
    setState(ctx, gl.BLEND, blending);
    if (blending) {
      ctx.blendEquation(blendEquation);
      ctx.blendFunc(sfactor, dfactor);
    }
  }

  setState(gl.RenderingContext ctx, int cap, bool enable) {
    if (enable) {
      ctx.enable(cap);
    } else {
      ctx.disable(cap);
    }
  }
}





























