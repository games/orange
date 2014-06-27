part of orange_examples;




class TestBabylonViperScene extends Scene {
  TestBabylonViperScene(Camera camera) : super(camera);

  @override
  void enter() {

    var loader = new BabylonLoader();
    loader.load(graphicsDevice.ctx, "/orange/models/babylon/Viper/Viper.babylon", new BabylonViperScene()).then((s) {
      if (s.camera == null) {
        s.camera = camera;
      }
      engine.enter(s);
    });
  }

}

class BabylonViperScene extends Scene {

  @override
  void enter() {
    var boundingInfo = BoundingInfo.compute(nodes);
    var box = boundingInfo.boundingBox;
    var radius = boundingInfo.boundingSphere.radius;
    camera.position = box.center + new Vector3(-radius, radius, radius);
    camera.lookAt(box.center);

//    nodes.forEach((n) {
//      if (n is Mesh && n.material != null) n.material.wireframe = true;
//    });
  }

}
