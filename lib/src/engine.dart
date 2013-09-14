part of orange;


class Engine {
  html.CanvasElement canvas;
  Renderer renderer;
  
  Engine._internal(this.canvas) {
    renderer = new Renderer(canvas);
  }
  
}