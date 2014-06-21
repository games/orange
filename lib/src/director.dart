part of orange;




class Director {

  static const double Epsilon = 0.001;
  static const double CollisionsEpsilon = 0.001;
  static Director _instance;
  static Director get instance => _instance;

  GraphicsDevice graphicsDevice;
  Scene _scene;
  num _lastElapsed = 0.0;
  BoundingBoxRenderer _boundingBoxRenderer;
  BoundingBoxRenderer get boundingBoxRenderer => _boundingBoxRenderer;

  factory Director(GraphicsDevice graphicsDevice) {
    if (_instance == null) _instance = new Director._(graphicsDevice);
    return _instance;
  }

  Director._(this.graphicsDevice) {
    _boundingBoxRenderer = new BoundingBoxRenderer(graphicsDevice);
  }

  replace(Scene scene) {
    if (_scene != null) {
      _scene.exit();
    }
    _scene = scene;
    _scene.director = this;
    _scene.enter();
  }

  run() => html.window.requestAnimationFrame(_animate);

  _animate(num elapsed) {
    run();
    final interval = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (_scene != null) {
      _scene.enterFrame(elapsed, interval);
      // animations
      _scene.nodes.forEach((node) {
        if (node is Mesh) {
          if (node.animator != null) node.animator.evaluate(interval);
          if (node.showBoundingBox) _boundingBoxRenderer._renderList.add(node.boundingInfo.boundingBox);
        }
      });
      //physics
      if (_scene._physicsEngine != null) {
        _scene._physicsEngine._runOneStep(interval / 1000.0);
      }
      graphicsDevice.render(_scene);
      // bounding boxes
      _boundingBoxRenderer.render();

      _scene.exitFrame();
      _boundingBoxRenderer._renderList.clear();
    }
  }

  Scene get scene => _scene;
}
