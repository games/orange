part of orange;


typedef void UpdateHandler(num interval);


class Director {
  static Director _shared;
  static Director get shared => _shared; 
  
  html.CanvasElement _canvas;
  Renderer _renderer;
  Scene _scene;
  double _lastElapsed;
  EventDispatcher<num> _onTick;
  
  factory Director(html.CanvasElement canvas) {
    if(_shared == null){
      _shared = new Director._internal(canvas);
    }
    return _shared;
  }
  
  Director._internal(this._canvas) {
    _renderer = new Renderer(_canvas);
    _lastElapsed = 0.0;
    _onTick = new EventDispatcher(this);
  }
  
  replace(Scene scene) {
    if(_scene != null) _scene.exit();
    _scene = scene;
    _scene.enter();
  }
  
  startup() {
    html.window.requestAnimationFrame(_animate);
  }
  
  _animate(num elapsed) {
    html.window.requestAnimationFrame(_animate);
    var interval = elapsed - _lastElapsed;
    _scene.update(interval);
    _onTick.dispatch(interval);
    _scene.camera.updateMatrixWorld();
    _renderer.prepare();
    _renderer.render(_scene);
    _lastElapsed = elapsed;
  }
  
  double get elapsed => _lastElapsed;
  Renderer get renderer => _renderer;
  Scene get scene => _scene;
  html.CanvasElement get canvas => _canvas;
  EventDispatcher<num> get onTick => _onTick;
}






