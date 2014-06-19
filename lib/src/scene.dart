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

  List<Node> _nodes = [];
  List<Mesh> _opaqueMeshes = [];
  List<Mesh> _alphaTestMeshes = [];
  List<Mesh> _transparentMeshes = [];
  List<Light> _lights = [];

  bool lightsEnabled = true;
  bool texturesEnabled = true;
  bool autoClear = true;
  bool forceWireframe = false;

  Director director;
  PerspectiveCamera camera;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  GraphicsDevice get graphicsDevice => director != null ? director.graphicsDevice : null;

  Scene(this.camera);

  add(Node node) {
    node.scene = this;
    if (node is Mesh) {
      _opaqueMeshes.add(node);
    } else if (node is Light) {
      _lights.add(node);
    }
    _nodes.add(node);
    if (node.name == null) {
      node.name = "Node${_nodes.length}";
    }
  }

  remove(Node node) {
    if (node is Mesh) {
      _opaqueMeshes.remove(node);
    } else if (node is Light) {
      _lights.remove(node);
    }
    _nodes.remove(node);
    node.scene = null;
  }

  enter();

  update(num elapsed, num interval) {
    _nodes.forEach((node) {
      if (node is Mesh && node.animator != null) node.animator.evaluate(interval);
    });
  }

  exit();
}
