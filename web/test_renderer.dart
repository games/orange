import 'dart:html' as html;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';





class TestLightingScene extends Scene {

  TestLightingScene(PerspectiveCamera camera) : super(camera);

  Mesh box, sphere, plane, sphere2, sphere3;
  PointLight pointLight0;
  SpotLight spotLight;

  @override
  enter() {
    camera.position.setValues(0.0, 5.0, 8.0);
    camera.lookAt(new Vector3.zero());

    box = new Cube();
    box.position.setValues(-1.0, 0.5, 0.0);
    box.material = new StandardMaterial();
    box.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    box.material.diffuseColor = new Color.fromHex(0xffffff);
    add(box);

    sphere = new SphereMesh();
    sphere.position.setValues(2.0, 1.0, 0.0);
    sphere.material = new StandardMaterial();
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);
    add(sphere);

    sphere2 = new SphereMesh(radius: 0.2);
    sphere2.material = new StandardMaterial();
    sphere2.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere2.material.diffuseColor = new Color.fromHex(0x0000ff);
    add(sphere2);

    sphere3 = new SphereMesh(radius: 0.2);
    sphere3.material = new StandardMaterial();
    sphere3.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere3.material.diffuseColor = new Color.fromHex(0xff0000);
    add(sphere3);

    plane = new PlaneMesh(width: 10, height: 10);
    plane.rotation.setAxisAngle(Axis.X, -PI / 2);
    plane.position.setValues(0.0, 0.0, 0.0);
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    add(plane);

    var textureManager = new TextureManager();
    textureManager.load(graphicsDevice.ctx, {
      "path": "cubetexture.png"
    }).then((t) {
      box.material.diffuseTexture = t;
      sphere.material.diffuseTexture = t;
    });

    pointLight0 = new PointLight(0xffffff);
    pointLight0.position = new Vector3(-5.0, 3.0, 0.0);
    pointLight0.diffuse = new Color.fromHex(0xff0000);
    add(pointLight0);

    spotLight = new SpotLight(0xffffff);
    spotLight.angle = 18.0;
    spotLight.exponent = 2.0;
    spotLight.intensity = 0.5;
    spotLight.position.setValues(5.0, 2.0, 0.0);
    spotLight.direction = new Vector3(-1.4, -1.0, 0.0);
    spotLight.diffuse = new Color.fromHex(0x00ff00);
    spotLight.specular = new Color.fromHex(0xffffff);
    add(spotLight);
  }

  @override
  enterFrame(num elapsed, num interval) {
    super.enterFrame(elapsed, interval);

    pointLight0.position.setValues(cos(elapsed / 1000) * 5.0, 3.0, sin(elapsed / 1000) * 5.0);

    sphere2.position = spotLight.position;
    sphere3.position = pointLight0.position;

//    box.rotation.rotateY(interval / 1000);
//    sphere.rotation.rotateY(interval / 1000);
    //    camera.update(interval);
    //    camera.position.setValues(cos(elapsed / 1000) * 8.0, 5.0, sin(elapsed / 1000) * 8.0);
    //    camera.lookAt(new Vector3.zero());
  }


  @override
  exit() {
    super.exit();
    removeChildren();
  }
}
