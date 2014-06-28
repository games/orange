part of orange_examples;





class TestLightingScene2 extends Scene {

  TestLightingScene2(Camera camera) : super(camera);

  Light light0, light1, light2;
  DirectionalLight light3;
  SphereMesh sphere0, sphere1, sphere2, sphere;

  @override
  enter() {

    camera.setTranslation(-10.0, 20.0, 0.0);
    camera.lookAt(new Vector3.zero());

    light0 = new PointLight(0xff0000);
    light0.specular = new Color.float(1.0, 0.0, 0.0);
    light0.setTranslation(0.0, 10.0, 0.0);
    add(light0);

    light1 = new PointLight(0x00ff00);
    light1.specular = new Color.float(0.0, 1.0, 0.0);
    light1.setTranslation(0.0, -10.0, 0.0);
    add(light1);

    light2 = new PointLight(0x0000ff);
    light2.specular = new Color.float(0.0, 0.0, 1.0);
    light2.setTranslation(10.0, 0.0, 0.0);
    add(light2);

    light3 = new DirectionalLight(0xffffff);
    light3.specular = new Color.float(1.0, 1.0, 1.0);
    light3.direction = new Vector3(1.0, -1.0, 0.0);
    add(light3);

    sphere0 = new SphereMesh(widthSegments: 16, heightSegments: 16, radius: 0.5);
    sphere0.material = new StandardMaterial();
    sphere0.material.diffuseColor = new Color.fromHex(0x0);
    sphere0.material.specularColor = new Color.fromHex(0x0);
    sphere0.material.emissiveColor = new Color.fromHex(0xff0000);
    add(sphere0);

    sphere1 = new SphereMesh(widthSegments: 16, heightSegments: 16, radius: 0.5);
    sphere1.material = new StandardMaterial();
    sphere1.material.diffuseColor = new Color.fromHex(0x0);
    sphere1.material.specularColor = new Color.fromHex(0x0);
    sphere1.material.emissiveColor = new Color.fromHex(0x00ff00);
    add(sphere1);

    sphere2 = new SphereMesh(widthSegments: 16, heightSegments: 16, radius: 0.5);
    sphere2.material = new StandardMaterial();
    sphere2.material.diffuseColor = new Color.fromHex(0x0);
    sphere2.material.specularColor = new Color.fromHex(0x0);
    sphere2.material.emissiveColor = new Color.fromHex(0x0000ff);
    add(sphere2);

    sphere = new SphereMesh(widthSegments: 32, heightSegments: 32, radius: 3);
    sphere.material = new StandardMaterial();
    sphere.material.diffuseColor = new Color.fromHex(0xffffff);
    add(sphere);
  }

  var alpha = 0.0;

  @override
  enterFrame(num elapsed, num interval) {
    light0.position = new Vector3(10 * sin(alpha), 0.0, 10 * cos(alpha));
    light1.position = new Vector3(10 * sin(alpha), 0.0, -10 * cos(alpha));
    light2.position = new Vector3(10 * cos(alpha), 0.0, 10 * sin(alpha));

    sphere0.position = light0.position;
    sphere1.position = light1.position;
    sphere2.position = light2.position;

    alpha += 0.01;
  }
  
  @override
  exit() {
    dispose();
  }
}







