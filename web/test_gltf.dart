import 'package:orange/orange.dart';



class TestGLTFScene extends Scene {

  TestGLTFScene(Camera camera) : super(camera);


  @override
  void enter() {
    var loader = new GltfLoader();
    loader.load(graphicsDevice.ctx, "../models/duck/duck.json").then((m) {
      
      add(m);
      
      
    });
  }
}
