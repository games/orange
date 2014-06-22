import 'package:orange/orange.dart';
import 'package:vector_math/vector_math.dart';



class TestGLTFScene extends Scene {

  TestGLTFScene(Camera camera) : super(camera);


  @override
  void enter() {

    camera.position.setValues(0.0, 200.0, 300.0);
    camera.lookAt(new Vector3.zero());

    var loader = new GltfLoader2();
    loader.load(graphicsDevice.ctx, "../models/duck/duck.json").then((m) {
      add(m);
    });

    var light0 = new PointLight(0xffffff);
    light0.intensity = 0.9;
    light0.position = new Vector3(-100.0, 300.0, 300.0);
    add(light0);

    var light1 = new DirectionalLight(0xffffff);
    light1.intensity = 0.2;
    light1.specular = new Color.fromHex(0xffffff);
    light1.position = new Vector3(100.0, 300.0, 300.0);
    light1.direction = new Vector3(-1.0, -1.0, 0.0).normalize();
    add(light1);
  }
  
  @override
  void exit() {
    super.exit();
    removeChildren();
  }
}
