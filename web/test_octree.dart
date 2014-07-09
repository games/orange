part of orange_examples;




class TestOctree extends Scene {

  TestOctree(Camera camera) : super(camera);

  Mesh box;
  Mesh sphere;
  html.LabelElement label;

  @override
  void enter() {

    ambientColor = new Color.fromHex(0xffffff);

    camera.setTranslation(0.0, 2.0, 4.0);
    camera.lookAt(new Vector3.zero());

    var material = new StandardMaterial();
    material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);

    box = new Cube(width: 0.5, height: 0.2, depth: 1);
    box.setTranslation(0.0, 0.0, -3.0);
    box.material = material;
    add(box);

    sphere = new SphereMesh(radius: 0.5);
    sphere.setTranslation(2.0, 0.0, 0.0);
    sphere.material = new StandardMaterial();
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([0.2, 1.0, 0.5]);
    add(sphere);

    var plane = new PlaneMesh(width: 2, height: 2);
    plane.rotate(Axis.X, -PI / 2);
    plane.setTranslation(0.0, 0.0, 0.0);
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    add(plane);

    var light0 = new PointLight(0xffffff);
    light0.position = new Vector3(-5.0, 3.0, 0.0);
    add(light0);


    label = new html.LabelElement();
    html.querySelector("#controllers").children.add(label);

    html.querySelector("#controllers").children.add(new html.BRElement());
    
    var duplicateBox = new html.ButtonElement();
    duplicateBox.onClick.listen((e) {
      for(var i = 0; i < 50; i++)
        _createBoxs();
      updateSelectionOctree();
    });
    duplicateBox.text = "Clone";
    html.querySelector("#controllers").children.add(duplicateBox);

    updateSelectionOctree();
  }

  _createBoxs() {
    var rnd = new Random();
    var newBox = [box, sphere][rnd.nextInt(2)].clone();
    newBox.setTranslation(rnd.nextDouble() * 10.0 - 2.0, rnd.nextDouble() * 10.0 - 1.0, rnd.nextDouble() * 10.0 - 1.0);
    newBox.scale(rnd.nextDouble());
    add(newBox);
  }

  @override
  void enterFrame(num elapsed, num interval) {
    box.position = new Vector3(0.0, 1.0, sin(elapsed / 1000) * 2.0);
    label.text = "Total: ${nodes.length - 1}, Selection: ${selectionOctree.selectionContent.length}";
  }

  @override
  void exit() {
    super.exit();
    removeChildren();
  }
}
