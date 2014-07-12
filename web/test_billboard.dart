part of orange_examples;



class TestBillboardScene extends Scene {

  TestBillboardScene(Camera camera) : super(camera);

  @override
  void enter() {

    ambientColor = new Color.fromHex(0xffffff);

    camera.setTranslation(0.0, 2.0, 4.0);
    camera.lookAt(new Vector3.zero());

    var plane = new PlaneMesh(width: 2, height: 2);
    plane.setTranslation(0.0, 0.0, 0.0);
    plane.billboardMode = Mesh.BILLBOARDMODE_ALL;
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.showBoundingBox = true;
    add(plane);

    var box = new Cube(width: 0.5, height: 0.2, depth: 1);
    box.setTranslation(0.0, 1.0, -1.0);
    box.material = new StandardMaterial();
    box.material.ambientColor = new Color.fromList([0.1, 0.3, 0.3]);
    box.material.diffuseColor = new Color.fromList([0.3, 1.0, 0.3]);
    box.showBoundingBox = true;
    add(box);

    addControls(createRadio("billboardx", "billboard", "Billboard X", (e) {
      plane.billboardMode = Mesh.BILLBOARDMODE_X;
    }));

    addControls(createRadio("billboardy", "billboard", "Billboard Y", (e) {
      plane.billboardMode = Mesh.BILLBOARDMODE_Y;
    }));

    addControls(createRadio("billboardz", "billboard", "Billboard Z", (e) {
      plane.billboardMode = Mesh.BILLBOARDMODE_Z;
    }));

    addControls(createRadio("billboardall", "billboard", "Billboard All", (e) {
      plane.billboardMode = Mesh.BILLBOARDMODE_ALL;
    }, true));

    var light0 = new PointLight(0xffffff);
    light0.position = new Vector3(-5.0, 3.0, 0.0);
    add(light0);

  }

  @override
  void enterFrame(num elapsed, num interval) {
  }

  @override
  void exit() {
    super.exit();
    removeChildren();
  }
}
