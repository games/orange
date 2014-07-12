part of orange;




class Orange {

  static const double Epsilon = 0.001;
  static const double CollisionsEpsilon = 0.001;

  static const int ALPHA_DISABLE = 0;
  static const int ALPHA_ADD = 1;
  static const int ALPHA_COMBINE = 2;

  static Orange _instance;
  static Orange get instance => _instance;

  GraphicsDevice graphicsDevice;
  Scene _scene;
  num _lastElapsed = 0.0;
  RenderingGroup _renderGroup = new RenderingGroup();
  BoundingBoxRenderer _boundingBoxRenderer;
  List<RenderTargetTexture> _renderTargets = [];
  List<ParticleSystem> _activeParticleSystems = [];
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
      if (node is Mesh && node.enabled && node.visible && node.visibility > 0) {
        if (node.animator != null) node.animator.evaluate(interval);
        if (node.material != null) {
          _renderGroup.register(node);
          _renderTargets.addAll(node.material._renderTargets);
        }
        if (node.showBoundingBox && node.boundingInfo != null) _boundingBoxRenderer._renderList.add(node.boundingInfo.boundingBox);
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
      _scene._animationRatio = interval * (60.0 / 1000.0);
      _scene.enterFrame(elapsed, interval);
      camera.update();
      camera.updateMatrix();
      if(_scene.frustum == null) _scene.frustum = new Frustum();
      _scene.frustum.setFromMatrix(camera.viewProjectionMatrix);

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
      
      //octree
      var nodes = _scene.nodes;
      if(_scene._selectionOctree != null) {
        nodes = _scene._selectionOctree.select(_scene.frustum.planes);
      }
      
      _prepare(nodes, interval);

      _activeParticleSystems.clear();
      scene._particleSystemds.forEach((sys) {
        if (!sys.stared) return;
        if (sys.emitter == null) return;
        if (sys.emitter is Node && !sys.emitter.enabled) return;
        _activeParticleSystems.add(sys);
        sys.animate();
      });

      var view = camera.viewMatrix;
      var viewProj = camera.viewProjectionMatrix;
      var proj = camera.projectionMatrix;
      var eye = camera.position;

      _renderTargets.forEach((renderTarget) => renderTarget.render(scene, view, viewProj, proj, eye));

      if (_renderTargets.length > 0) graphicsDevice.restoreDefaultFramebuffer();

      graphicsDevice.clear(scene.backgroundColor, backBuffer: scene.autoClear || scene.forceWireframe, depthStencil: true);
      _renderGroup.render(scene, view, viewProj, proj, eye);

      // bounding boxes
      _boundingBoxRenderer.render();

      // particles
      _activeParticleSystems.forEach((sys) => sys.render(scene, view, viewProj, proj, eye));

      graphicsDevice.ctx.flush();

      _scene.exitFrame();

      //after render callbacks
      afterRenders.forEach((c) => c());

      _scene._shouldDisposes.forEach((d) => d.dispose());
      _scene._shouldDisposes.clear();
      _renderGroup.clear();
      _boundingBoxRenderer._renderList.clear();
      _renderTargets.clear();
    }
  }

  Scene get scene => _scene;
}
