part of orange;


class Renderer {
  gl.RenderingContext ctx;
  
  Renderer(html.CanvasElement canvas) {
    ctx = canvas.getContext3d(preserveDrawingBuffer: true);
  }
}