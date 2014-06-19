part of orange;




class Director {

  static const double Epsilon = 0.001;
  static const double CollisionsEpsilon = 0.001;

  GraphicsDevice graphicsDevice;
  Scene _scene;
  num _lastElapsed = 0.0;

  Director(this.graphicsDevice);

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
      _scene.update(elapsed, interval);
      graphicsDevice.render(_scene);
    }
  }

}
