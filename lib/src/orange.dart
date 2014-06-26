part of orange;




class Orange {

  static const double Epsilon = 0.001;
  static const double CollisionsEpsilon = 0.001;
  static Orange _instance;
  static Orange get instance => _instance;

  GraphicsDevice graphicsDevice;
  Scene _scene;
  num _lastElapsed = 0.0;
  RenderingGroup _renderGroup = new RenderingGroup();
  BoundingBoxRenderer _boundingBoxRenderer;
  List<RenderTargetTexture> _renderTargets = [];
  List<Callback> afterRenders = [];

  factory Orange(GraphicsDevice graphicsDevice) {
    if (_instance == null) _instance = new Orange._(graphicsDevice);
    return _instance;
  }

  Orange._(this.graphicsDevice) {
    _boundingBoxRenderer = new BoundingBoxRenderer(graphicsDevice);
  }

  enter(Scene scene) {
    if (_scene != null) {
      _scene.exit();
    }
    _scene = scene;
    _scene.engine = this;
    _scene.enter();
  }

  run() => html.window.requestAnimationFrame(_animate);

  _prepare(List<Node> nodes, num interval) {
    nodes.forEach((node) {
      node.updateMatrix(false);
      if (node is Mesh) {
        if (node.animator != null) node.animator.evaluate(interval);
        if (node.material != null) {
          _renderGroup.register(node);
          _renderTargets.addAll(node.material._renderTargets);
        }
        if (node.showBoundingBox) _boundingBoxRenderer._renderList.add(node.boundingInfo.boundingBox);
      }
      _prepare(node.children, interval);
    });
  }

  _animate(num elapsed) {
    run();
    final interval = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (_scene != null && _scene.camera != null) {
      var camera = _scene.camera;
      _scene._elapsed = elapsed;
      _scene._interval = interval;
      _scene.enterFrame(elapsed, interval);
      camera.update();
      // .camera.updateMatrix();

      //physics
      if (_scene._physicsEngine != null) {
        _scene._physicsEngine._runOneStep(interval / 1000.0);
      }

      // shadows
      scene._lights.forEach((light) {
        if (light is DirectionalLight && light.enabled) {
          if (light.shadowRenderer == null) light.shadowRenderer = new ShadowRenderer(512, light, graphicsDevice);
          _renderTargets.add(light.shadowRenderer.shadowMap);
        }
      });

      _prepare(_scene.nodes, interval);

      _renderTargets.forEach((renderTarget) {
        renderTarget.render(scene, camera.viewMatrix, camera.viewProjectionMatrix, camera.projectionMatrix, camera.position);
      });

      if (_renderTargets.length > 0) graphicsDevice.restoreDefaultFramebuffer();

      graphicsDevice.clear(scene.backgroundColor, backBuffer: scene.autoClear || scene.forceWireframe, depthStencil: true);
      _renderGroup.render(scene, camera.viewMatrix, camera.viewProjectionMatrix, camera.projectionMatrix, camera.position);

      // bounding boxes
      _boundingBoxRenderer.render();

      graphicsDevice.ctx.flush();
      
      _scene.exitFrame();
      
      //after render callbacks
      afterRenders.forEach((c) => c());

      _renderGroup.clear();
      _boundingBoxRenderer._renderList.clear();
      _renderTargets.clear();
    }
  }

  Scene get scene => _scene;
}
