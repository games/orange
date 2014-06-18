part of orange;




class Director {

  GraphicsDevice device;
  Scene _scene;
  num _lastElapsed = 0.0;

  Director(this.device);

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
      device.render(_scene);
    }
  }

}
