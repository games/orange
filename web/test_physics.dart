import 'dart:html' as html;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';


class PhysicsScene extends Scene {

  PhysicsScene(PerspectiveCamera camera) : super(camera);

  @override
  enter() {
    camera.position.setValues(0.0, 2.0, 4.0);
    camera.lookAt(new Vector3.zero());

    enablePhysics();

    var sphere = new SphereMesh(radius: 0.5);
    sphere.position.setValues(0.0, 0.0, -1.0);
    sphere.material = new StandardMaterial();
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);
    sphere.showBoundingBox = true;
    add(sphere);
    sphere.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 1.0));

    var sphere1 = new SphereMesh(radius: 0.5);
    sphere1.position.setValues(0.0, 2.0, -1.0);
    sphere1.material = new StandardMaterial();
    sphere1.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere1.material.diffuseColor = new Color.fromList([1.0, 1.0, 1.0]);
    sphere1.showBoundingBox = true;
    add(sphere1);
    sphere1.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 1.0));

    var plane = _createPlane(2.0);//  new PlaneMesh(width: 10, height: 10);
    plane.rotation.setAxisAngle(Axis.X, -PI / 2);
    plane.position.setValues(0.0, -2.0, -1.0);
    plane.material = new StandardMaterial();
    plane.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    plane.material.diffuseColor = new Color.fromHex(0xFFFFFF);
    plane.receiveShadows = true;
    plane.castShadows = false;
    plane.showBoundingBox = true;
    add(plane);
    plane.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(mass: 0.0, friction: 0.5, restitution: 0.7));

    var gound = new Cube(width: 5, height: 0.2, depth: 5);
    gound.position.setValues(0.0, -1.0, -1.0);
    gound.material = new StandardMaterial();
    gound.material.ambientColor = new Color.fromList([0.5, 0.0, 0.3]);
    gound.material.diffuseColor = new Color.fromHex(0xFFFFFF);
    gound.receiveShadows = true;
    gound.castShadows = false;
    gound.showBoundingBox = true;
    add(gound);
    gound.setPhysicsState(PhysicsEngine.BoxImpostor, new PhysicsBodyCreationOptions(mass: 0.0, friction: 0.5, restitution: 0.7));

    var textureManager = new TextureManager();
    textureManager.load(graphicsDevice.ctx, {
      "path": "mosaic.jpg"
    }).then((t) {
      sphere.material.diffuseTexture = t;
      sphere1.material.diffuseTexture = t;
    });
    textureManager.load(graphicsDevice.ctx, {
      "path": "cubetexture.png"
    }).then((t) {
//      plane.material.diffuseTexture = t;
    });
    textureManager.load(graphicsDevice.ctx, {
      "path": "bump.png"
    }).then((t) {
//      plane.material.bumpTexture = t;
    });

    var light0 = new PointLight(0xffffff);
    light0.position = new Vector3(-5.0, 3.0, 0.0);
    add(light0);
  }

  @override
  exit() {
    super.exit();
  }
}

Mesh _createPlane([double scale = 1.0]) {
  var mesh = new PolygonMesh();
  mesh.setVertices([-scale, -scale, 1.0, scale, -scale, 1.0, scale, scale, 1.0, -scale, scale, 1.0]);
  mesh.setFaces([0, 1, 2, 0, 2, 3]);
  mesh.setTexCoords([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]);
  mesh.calculateSurfaceNormals();
  return mesh;
}
