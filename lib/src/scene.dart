part of orange;


abstract class Scene {
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

  List<Node> nodes = [];
  List<Mesh> _opaqueMeshes = [];
  List<Mesh> _alphaTestMeshes = [];
  List<Mesh> _transparentMeshes = [];
  List<Light> _lights = [];

  bool lightsEnabled = true;
  bool texturesEnabled = true;
  bool autoClear = true;
  bool forceWireframe = false;

  @deprecated
  Director director;
  GraphicsDevice get graphicsDevice => Director.instance.graphicsDevice;
  Camera camera;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  PhysicsEngine _physicsEngine;
  PhysicsEngine get physicsEngine => _physicsEngine;
  bool get physicsEnabled => _physicsEngine != null;

  Scene(this.camera) {

  }

  bool enablePhysics({Vector3 gravity, PhysicsEnginePlugin plugin}) {
    if (_physicsEngine != null) return true;
    _physicsEngine = new PhysicsEngine(plugin);
    if (!_physicsEngine.supported) {
      _physicsEngine = null;
      return false;
    }
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
    if (node is Mesh) {
      _opaqueMeshes.add(node);
    } else if (node is Light) {
      _lights.add(node);
    }
    nodes.add(node);
    if (node.name == null) {
      node.name = "Node${nodes.length}";
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

  void enter();

  void enterFrame(num elapsed, num interval) {

  }

  void exitFrame() {

  }

  void exit() {
    // TODO release all resources
  }
}
