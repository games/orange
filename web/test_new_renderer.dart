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

  Mesh box;

  @override
  enter() {
    camera.position.setValues(0.0, 2.0, 5.0);
    camera.lookAt(new Vector3.zero());

    box = new Cube();
    box.position.setValues(0.0, 0.5, 0.0);
    box.material = new StandartMaterial(this);
    box.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    box.material.diffuseColor = new Color.fromHex(0xff0000);
    nodes.add(box);

    var textureManager = new TextureManager();
    textureManager.load(renderer.ctx, {
      "path": "cubetexture.png"
    }).then((t) {
      box.material.diffuseTexture = t;
    });

    var plane = new Plane(width: 10, height: 10);
    plane.rotation.rotateX(-PI / 2);
    plane.position.setValues(0.0, 0.0, 0.0);
    plane.material = new StandartMaterial(this);
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    nodes.add(plane);

    var pointLight = new PointLight(0xffffff);
    pointLight.position = new Vector3(15.0, 15.0, 15.0);
    pointLight.diffuse = new Color.fromHex(0xff0000);
//    lights.add(pointLight);
    
    var spotLight = new SpotLight(0xffffff);
    spotLight.diffuse = new Color.fromHex(0x00ff00);
    lights.add(spotLight);
  }

  @override
  update(num elapsed, num interval) {
    box.rotation.rotateY(interval / 1000);
  }


  @override
  exit() {
    // TODO: implement exit
  }
}
