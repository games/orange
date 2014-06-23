import 'dart:html' as html;
import 'package:orange/orange.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';




class TestAnimationScene extends Scene {
  TestAnimationScene(Camera camera): super(camera);
  Mesh mesh;
  bool rotateCamera = false;

  @override
  enter() {

    var controllers = html.querySelector("#controllers");
    camera.translate(0.0, 2.0, 4.0);
    camera.lookAt(new Vector3.zero());
    
    var url = "http://127.0.0.1:3030/orange/models/ogre/alric.orange";
    var loader = new OgreLoader();
    loader.load(graphicsDevice.ctx, url).then((m) {
      m.position.setValues(0.0, -1.0, -1.0);
      m.animator.switchAnimation("Idle");
      m.animator.animations.forEach((n, a) {
        var row = new html.DivElement();
        row.className = "row";
        var radio = _createAnimationSelector(n, a);
        var label = new html.LabelElement();
        label.htmlFor = radio.id;
        label.text = n;
        row.children.add(radio);
        row.children.add(label);
        controllers.children.add(row);
      });
      add(m);
      m.receiveShadows = false;
      m.castShadows = true;
      m.showBoundingBox = true;
      mesh = m;
    });

    var row = new html.DivElement();
    row.className = "row";
    var radio = new html.CheckboxInputElement();
    radio.id = "rotate_camera";
    radio.name = "rotate_camera";
    radio.value = "rotate_camera";
    radio.onClick.listen((e) {
      rotateCamera = !rotateCamera;
    });
    var label = new html.LabelElement();
    label.htmlFor = radio.id;
    label.text = "Rotate Camera";
    row.children.add(radio);
    row.children.add(label);
    controllers.children.add(row);

    var plane = _createPlane(6.0);// new Plane(width: 10, height: 10);
    plane.rotation.setAxisAngle(Axis.X, -PI / 2);
    plane.translate(0.0, -2.0, -3.5);
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromHex(0xFFFFFF);
    plane.receiveShadows = true;
    plane.castShadows = false;
    add(plane);

    var sphere = new SphereMesh(radius: 0.5);
    sphere.translate(2.0, 1.0, 0.0);
    sphere.material = new StandardMaterial();
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);
    add(sphere);

    var textureManager = new TextureManager();
    textureManager.load(graphicsDevice.ctx, {
      "path": "bump.png"
    }).then((t) {
      sphere.material.bumpTexture = t;
      plane.material.bumpTexture = t;
    });
    textureManager.load(graphicsDevice.ctx, {
      "path": "cubetexture.png"
    }).then((t) {
      sphere.material.diffuseTexture = t;
    });

    var spotLight = new SpotLight(0xffffff);
    spotLight.angle = 3.0;
    spotLight.exponent = 2.0;
    spotLight.intensity = 0.1;
    spotLight.translate(5.0, 2.0, -1.0);
    spotLight.direction = new Vector3(-2.8, -1.0, -0.3);
    spotLight.diffuse = new Color.fromHex(0x00ff00);
    spotLight.specular = new Color.fromHex(0xffffff);
    add(spotLight);

    var light2 = new DirectionalLight(0x0000ff);
    light2.position = new Vector3(-5.0, 3.0, 0.0);
    light2.direction = new Vector3(2.8, -1.0, -0.2);
    light2.diffuse = new Color.fromHex(0xff0000);
    add(light2);

    enablePhysics();
  }

  html.RadioButtonInputElement _createAnimationSelector(String name, Animation animation) {
    var radio = new html.RadioButtonInputElement();
    radio.id = name;
    radio.name = "animation";
    radio.value = name;
    radio.onClick.listen((e) {
      mesh.animator.switchAnimation(name);
    });
    return radio;
  }

  @override
  exit() {
    super.exit();
    removeChildren();
  }

  num _elapsed = 0;

  @override
  enterFrame(num elapsed, num interval) {
    super.enterFrame(elapsed, interval);

    if (rotateCamera) {
      _elapsed += interval;
      camera.position.setValues(cos(_elapsed / 1000) * 4.0, 2.0, sin(_elapsed / 1000) * 4.0);
//      camera.lookAt(new Vector3.zero());
    }
  }
}

Mesh _createPlane([double scale = 1.0]) {
  var mesh = new PolygonMesh();
  mesh.setPositions([-scale, -scale, 1.0, scale, -scale, 1.0, scale, scale, 1.0, -scale, scale, 1.0]);
  mesh.setIndices([0, 1, 2, 0, 2, 3]);
  mesh.setTexCoords([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]);
  mesh.calculateSurfaceNormals();
  return mesh;
}
