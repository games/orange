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
  List<Light> lights = [];

  bool lightsEnabled = true;
  bool texturesEnabled = true;

  Director director;
  PerspectiveCamera camera;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  Renderer2 get renderer => director != null ? director.renderer : null;

  Scene(this.camera);

  enter();
  update(num elapsed, num interval);
  exit();
}
