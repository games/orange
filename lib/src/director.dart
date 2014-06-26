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
  List<Callback> afterRenders = [];

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

  _prepare(List<Node> nodes, num interval) {
    nodes.forEach((node) {
      node.updateMatrix(false);
      if (node is Mesh) {
        if (node.animator != null) node.animator.evaluate(interval);
        if (node.material != null) graphicsDevice._renderGroup.register(node);
        if (node.showBoundingBox) _boundingBoxRenderer._renderList.add(node.boundingInfo.boundingBox);
      }
      _prepare(node.children, interval);
    });
  }

  _animate(num elapsed) {
    run();
    final interval = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (_scene != null) {
      _scene._elapsed = elapsed;
      _scene._interval = interval;
      _scene.enterFrame(elapsed, interval);
      _scene.camera.update();
      //      _scene.camera.updateMatrix();

      //physics
      if (_scene._physicsEngine != null) {
        _scene._physicsEngine._runOneStep(interval / 1000.0);
      }

      // shadows
      scene._lights.forEach((light) {
        if (light is DirectionalLight && light.enabled) {
          if (light.shadowRenderer == null) light.shadowRenderer = new ShadowRenderer(512, light, graphicsDevice);
          graphicsDevice._renderTargets.add(light.shadowRenderer.shadowMap);
        }
      });

      _prepare(_scene.nodes, interval);

      graphicsDevice.render(_scene);
      // bounding boxes
      _boundingBoxRenderer.render();

      _scene.exitFrame();
      graphicsDevice._renderGroup.clear();
      _boundingBoxRenderer._renderList.clear();
      //after render callbacks
      afterRenders.forEach((c) => c());
    }
  }

  Scene get scene => _scene;
}
