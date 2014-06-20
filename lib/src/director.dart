part of orange;




class Director {

  static const double Epsilon = 0.001;
  static const double CollisionsEpsilon = 0.001;
  static Director _instance;
  static Director get instance => _instance;

  GraphicsDevice graphicsDevice;
  Scene _scene;
  num _lastElapsed = 0.0;

  factory Director(GraphicsDevice graphicsDevice) {
    if (_instance == null) _instance = new Director._(graphicsDevice);
    return _instance;
  }

  Director._(this.graphicsDevice);

  replace(Scene scene) {
    if (_scene != null) {
      _scene.exit();
    }
    scene.director = this;
    scene.enter();
    _scene = scene;
  }

  run() => html.window.requestAnimationFrame(_animate);

  _animate(num elapsed) {
    run();
    final interval = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (_scene != null) {
      _scene.enterFrame(elapsed, interval);
      _scene.exitFrame();
    }
  }
  
  Scene get scene => _scene;
}
