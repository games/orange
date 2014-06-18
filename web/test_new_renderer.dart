import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';


class TestNewRenderer {

  run() {
    var canvas = html.querySelector("#container");
    var renderer = new Renderer2(canvas);
    var director = new Director(renderer);
    director.replace(new MyScene(new PerspectiveCamera(canvas.width / canvas.height)));
    director.run();
  }
}


class MyScene extends Scene {

  MyScene(PerspectiveCamera camera) : super(camera);

  Mesh box, sphere, plane, sphere2, sphere3;
  PointLight pointLight0;
  SpotLight spotLight;

  @override
  enter() {
    camera.position.setValues(0.0, 5.0, 8.0);
    camera.lookAt(new Vector3.zero());

    box = new Cube();
    box.position.setValues(-1.0, 0.5, 0.0);
    box.material = new StandardMaterial(this);
    box.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    box.material.diffuseColor = new Color.fromHex(0xffffff);
    nodes.add(box);

    sphere = new Sphere();
    sphere.position.setValues(2.0, 1.0, 0.0);
    sphere.material = new StandardMaterial(this);
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);
    nodes.add(sphere);

    sphere2 = new Sphere(radius: 0.2);
    sphere2.material = new StandardMaterial(this);
    sphere2.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere2.material.diffuseColor = new Color.fromHex(0x0000ff);
    nodes.add(sphere2);

    sphere3 = new Sphere(radius: 0.2);
    sphere3.material = new StandardMaterial(this);
    sphere3.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere3.material.diffuseColor = new Color.fromHex(0xff0000);
    nodes.add(sphere3);

    plane = new Plane(width: 10, height: 10);
    plane.rotation.rotateX(-PI / 2);
    plane.position.setValues(0.0, 0.0, 0.0);
    plane.material = new StandardMaterial(this);
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    nodes.add(plane);

    var textureManager = new TextureManager();
    textureManager.load(renderer.ctx, {
      "path": "cubetexture.png"
    }).then((t) {
      box.material.diffuseTexture = t;
      sphere.material.diffuseTexture = t;
    });

    pointLight0 = new PointLight(0xffffff);
    pointLight0.position = new Vector3(-5.0, 3.0, 0.0);
    pointLight0.diffuse = new Color.fromHex(0xff0000);
    lights.add(pointLight0);

    spotLight = new SpotLight(0xffffff);
    spotLight.angle = 18.0;
    spotLight.spotExponent = 2.0;
    spotLight.intensity = 0.5;
    spotLight.position.setValues(5.0, 2.0, 0.0);
    spotLight.direction = new Vector3(-1.4, -1.0, 0.0);
    spotLight.diffuse = new Color.fromHex(0x00ff00);
    spotLight.specular = new Color.fromHex(0xffffff);
    lights.add(spotLight);
  }

  @override
  update(num elapsed, num interval) {
    
    pointLight0.position.setValues(cos(elapsed / 1000) * 5.0, 3.0, sin(elapsed / 1000) * 5.0);

    sphere2.position = spotLight.position;
    sphere3.position = pointLight0.position;
    
    box.rotation.rotateY(interval / 1000);
    sphere.rotation.rotateY(interval / 1000);
    //    camera.update(interval);
    //    camera.position.setValues(cos(elapsed / 1000) * 8.0, 5.0, sin(elapsed / 1000) * 8.0);
    //    camera.lookAt(new Vector3.zero());
  }


  @override
  exit() {
    // TODO: implement exit
  }
}
