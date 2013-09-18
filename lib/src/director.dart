part of orange;


class Director {
  html.CanvasElement _canvas;
  Renderer _renderer;
  Scene _scene;
  double _lastElapsed;
  Keyboard _keyboard;
  
  Director._internal(this._canvas) {
    _renderer = new Renderer(_canvas);
    _keyboard = new Keyboard();
    _lastElapsed = 0.0;
  }
  
  replace(Scene scene) {
    if(_scene != null) _scene.exit();
    _scene = scene;
    _scene.enter();
  }
  
  Keyboard get keyboard => _keyboard;
  Renderer get renderer => _renderer;
  Scene get scene => _scene;
  html.CanvasElement get canvas => _canvas;
  
  run() {
    html.window.requestAnimationFrame(_animate);
  }
  
  _animate(num elapsed) {
    html.window.requestAnimationFrame(_animate);
    var interval = elapsed - _lastElapsed;
    _renderer.prepare();
    _scene.update(interval);
    _keyboard.update(interval);
    _scene.camera.updateMatrix();
    _scene.render();
    _lastElapsed = elapsed;
  }
}






