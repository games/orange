part of orange_examples;




class TestObjLoader extends Scene {
  TestObjLoader(Camera camera) : super(camera);

  @override
  void enter() {

    var urls = [
                "models/obj/Head_max_obj/Infinite-Level_02.obj",
                "models/obj/head.obj", 
                "models/obj/train.obj", 
                "models/obj/female02/female02.obj", 
                "models/obj/cow-nonormals.obj", 
                "models/obj/pumpkin_tall_10k.obj", 
                "models/obj/teapot.obj", 
                "models/obj/teddy.obj",
                "models/obj/tree.obj"];

    var selector = new html.SelectElement();
    urls.forEach((u) {
      var option = new html.OptionElement(data: u.split("/").last, value: u);
      selector.children.add(option);
    });
    selector.onChange.listen((e) {
      var opt = selector.options[selector.selectedIndex];
      _loadModel(opt.value);
    });
    html.querySelector("#controllers").children.add(selector);
    
    _loadModel(urls.first);
  }
  
  void _loadModel(String url) {
    var loader = new ObjLoader();
    loader.load(url).then((m) {
      removeChildren();
      add(m);
      
      m.material = new StandardMaterial();
      m.material.diffuseColor = new Color.float(0.7, 0.3, 0.3);
      m.material.backFaceCulling = false;
      var box = m.boundingInfo.boundingBox;
      var radius = m.boundingInfo.boundingSphere.radius;
      camera.position = box.center + new Vector3(0.0, radius * 0, radius * 2);
      camera.lookAt(box.center);
      
      var light2 = new HemisphericLight(0xffffff);
      add(light2);
      
      var light3 = new DirectionalLight(0xffffff);
      light3.specular = new Color.float(1.0, 1.0, 1.0);
      light3.direction = new Vector3(1.0, -1.0, -1.0);
      light3.intensity = 0.5;
      add(light3);
    });
  }

  @override
  void exit() {
    dispose();
  }
}
