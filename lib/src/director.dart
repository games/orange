part of orange;


class Director {
  html.CanvasElement _canvas;
  Renderer _renderer;
  Scene _scene;
  double _lastElapsed;
  
  Director._internal(this._canvas) {
    _renderer = new Renderer(_canvas);
    _lastElapsed = 0.0;
  }
  
  replace(Scene scene) {
    if(_scene != null) _scene.exit();
    _scene = scene;
    _scene.enter();
  }
  
  Renderer get renderer => _renderer;
  Scene get scene => _scene;
  html.CanvasElement get canvas => _canvas;
  
  run() {
    html.window.requestAnimationFrame(_animate);
  }
  
  _animate(num elapsed) {
    html.window.requestAnimationFrame(_animate);
    _renderer.prepare();
    _scene.update((elapsed - _lastElapsed) / 1000.0);
    _scene.render();
    _lastElapsed = elapsed;
  }
}