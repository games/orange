part of orange;


class Scene implements Disposable {
  static int FOGMODE_NONE = 0;
  static int FOGMODE_EXP = 1;
  static int FOGMODE_EXP2 = 2;
  static int FOGMODE_LINEAR = 3;

  // Fog
  int fogMode = Scene.FOGMODE_NONE;
  Color fogColor = new Color.fromList([0.2, 0.2, 0.3]);
  num fogDensity = 0.1;
  num fogStart = 0.0;
  num fogEnd = 1000.0;

  Plane clipPlane;

  List<Node> nodes = [];
  List<Mesh> _opaqueMeshes = [];
  List<Mesh> _alphaTestMeshes = [];
  List<Mesh> _transparentMeshes = [];
  List<Light> _lights = [];
  // TODO
  List<Disposable> _shouldDisposes = [];

  bool lightsEnabled = true;
  bool texturesEnabled = true;
  bool autoClear = true;
  bool forceWireframe = false;

  double _elapsed = 0.0;
  double _interval = 0.0;
  double _animationRatio = 0.0;
  double get elapsed => _elapsed;
  double get interval => _interval;
  double get animationRatio => _animationRatio;

  Orange engine;
  GraphicsDevice get graphicsDevice => Orange.instance.graphicsDevice;
  Camera camera;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  Color ambientColor = new Color.fromHex(0x0);

  // physics
  Vector3 _gravity;
  PhysicsEngine _physicsEngine;
  PhysicsEngine get physicsEngine => _physicsEngine;
  bool get physicsEnabled => _physicsEngine != null;

  // particles
  List<ParticleSystem> _particleSystemds = [];

  Scene([this.camera]);

  bool enablePhysics({Vector3 gravity, PhysicsEnginePlugin plugin}) {
    if (_physicsEngine != null) return true;
    _physicsEngine = new PhysicsEngine(plugin);
    if (!_physicsEngine.supported) {
      _physicsEngine = null;
      return false;
    }
    if (gravity == null) gravity = _gravity;
    _physicsEngine._initialize(gravity);
    return true;
  }

  void disablePhysics() {
    if (_physicsEngine == null) return;
    _physicsEngine.dispose();
    _physicsEngine = null;
  }

  void add(Node node) {
    node.scene = this;
    if (node is Mesh && node.material != null) {
      if (node.material.alpha == 1.0 && !node.material.technique.pass.blending) {
        _opaqueMeshes.add(node);
      } else {
        _transparentMeshes.add(node);
      }
    } else if (node is Light) {
      _lights.add(node);
    }
    nodes.add(node);
    if (node.id == null) {
      node.id = "Node${nodes.length}";
    }
  }

  void remove(Node node) {
    if (node is Mesh) {
      _opaqueMeshes.remove(node);
      if (_physicsEngine != null && node._physicImpostor != PhysicsEngine.NoImpostor) _physicsEngine._unregisterMesh(node);
    } else if (node is Light) {
      _lights.remove(node);
    }
    nodes.remove(node);
    node.scene = null;
  }

  void removeChildren() {
    nodes.clear();
    _lights.clear();
    _opaqueMeshes.clear();
    _transparentMeshes.clear();
  }

  void enter() {

  }

  // TODO remove parameters
  void enterFrame(num elapsed, num interval) {

  }

  void exitFrame() {

  }

  void exit() {
    // TODO release all resources
  }

  @override
  void dispose() {
    removeChildren();
    disablePhysics();
    _shouldDisposes.addAll(_particleSystemds);
    _shouldDisposes.forEach((d) => d.dispose());
    _shouldDisposes.clear();
  }
}
