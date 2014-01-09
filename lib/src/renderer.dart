part of orange;



class Renderer {
  html.CanvasElement canvas;
  gl.RenderingContext ctx;
  ModelCamera camera;
  double fov;
  Matrix4 projectionMatrix;
  
  Renderer(html.CanvasElement canvas) {
    this.canvas = canvas;
    ctx = canvas.getContext3d();
    camera = new ModelCamera(canvas);
    camera.distance = 4.0;
    camera.center = new Vector3(0.0, -1.0, 0.0);
    fov = 45.0;
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
    
    ctx.clearColor(0.0, 0.0, 0.2, 1.0);
    ctx.clearDepth(1.0);
    ctx.enable(gl.DEPTH_TEST);
    ctx.enable(gl.CULL_FACE);
    ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
  }
  
  resize() {
    ctx.viewport(0, 0, canvas.width, canvas.height);
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
  }
  
  drawFrame(Model model) {
    ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    if(model.complete) {
      model.draw(ctx, camera.viewMatrix, projectionMatrix);
    }
  }
}