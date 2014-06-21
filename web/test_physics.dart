import 'dart:html' as html;
import 'package:orange/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'dart:async';


class PhysicsScene extends Scene {

  PhysicsScene(PerspectiveCamera camera): super(camera);

  @override
  enter() {
    camera.position.setValues(0.0, 2.0, 10.0);
    camera.lookAt(new Vector3.zero());

    enablePhysics();


    var sphereMaterial = new StandardMaterial();

    var sphere = new SphereMesh(radius: 0.5);
    sphere.position.setValues(0.0, 0.0, -1.0);
    sphere.material = sphereMaterial;
    sphere.castShadows = true;
    sphere.showBoundingBox = true;
    sphere.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 1.0));
    add(sphere);

    var sphere1 = new SphereMesh(radius: 0.8);
    sphere1.position.setValues(-0.2, 2.0, -1.0);
    sphere1.material = sphereMaterial;
    sphere1.castShadows = true;
    sphere1.showBoundingBox = true;
    sphere1.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 10.0));
    add(sphere1);

    sphere.setPhysicsLinkWith(sphere1, new Vector3(0.0, 1.5, 0.0), new Vector3(0.0, -1.5, 0.0));

    var rnd = new Random();
    for (var i = 0; i < 12; i++) {
      var sphere2 = new SphereMesh(radius: 0.5 * rnd.nextDouble() + 0.3);
      sphere2.position.setValues(rnd.nextDouble() * 8 - 4, 3.0, rnd.nextDouble() * 8 - 4);
      sphere2.material = sphereMaterial;
      sphere2.castShadows = true;
      sphere2.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 1.0));
      add(sphere2);
    }

    var cube = new Cube();
    cube.position.setValues(3.0, 1.0, -1.0);
    cube.material = new StandardMaterial();
    cube.receiveShadows = true;
    cube.showBoundingBox = false;
    cube.castShadows = true;
    cube.setPhysicsState(PhysicsEngine.BoxImpostor, new PhysicsBodyCreationOptions(mass: 1.0));
    add(cube);

    new Timer.periodic(new Duration(seconds: 3), (t) {
      cube.applyImpulse(new Vector3(rnd.nextDouble() * 2, rnd.nextDouble() * 2, rnd.nextDouble() * 2), new Vector3(rnd.nextDouble(), rnd.nextDouble(), rnd.nextDouble()));
    });

    var groundMaterial = new StandardMaterial();
    groundMaterial.diffuseColor = new Color.fromList([0.5, 0.5, 0.5]);
    groundMaterial.emissiveColor = new Color.fromList([0.2, 0.2, 0.2]);

    var ground = new PlaneMesh(width: 10, height: 10, ground: true);
    ground.position.setValues(0.0, -2.0, 0.0);
    ground.material = groundMaterial;
    ground.receiveShadows = true;
    ground.castShadows = false;
    ground.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(ground);

    var border = new PlaneMesh(width: 10, height: 10, ground: true);//new Cube(width: 0.5, height: 5, depth: 5);
    border.position.setValues(-5.0, 0.0, 0.0);
    border.rotation.setAxisAngle(Axis.Z, -PI / 2);
    border.material = groundMaterial;
    border.receiveShadows = true;
    border.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(border);

    var border1 = new PlaneMesh(width: 10, height: 10, ground: true);
    border1.position.setValues(5.0, 0.0, 0.0);
    border1.rotation.setAxisAngle(Axis.Z, PI / 2);
    border1.material = groundMaterial;
    border1.receiveShadows = true;
    border1.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(border1);

    var border2 = new PlaneMesh(width: 10, height: 10, ground: true);
    border2.position.setValues(0.0, 0.0, -5.0);
    border2.rotation.setAxisAngle(Axis.X, PI / 2);
    border2.material = groundMaterial;
    border2.receiveShadows = true;
    border2.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(border2);

    var border3 = new PlaneMesh(width: 10, height: 10, ground: true);
    border3.position.setValues(0.0, 0.0, 5.0);
    border3.rotation.setAxisAngle(Axis.X, -PI / 2);
    border3.material = groundMaterial;
    border3.receiveShadows = true;
    border3.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    //    add(border3);



    var textureManager = new TextureManager();
    textureManager.load(graphicsDevice.ctx, {
      "path": "mosaic.jpg"
    }).then((t) {
      sphereMaterial.diffuseTexture = t;
    });
    textureManager.load(graphicsDevice.ctx, {
      "path": "wood.jpg"
    }).then((t) {
      cube.material.diffuseTexture = t;
    });
    //    textureManager.load(graphicsDevice.ctx, {
    //      "path": "bump.png"
    //    }).then((t) {
    //      //      plane.material.bumpTexture = t;
    //    });

    var light0 = new PointLight(0xffffff);
    light0.intensity = 0.9;
    light0.position = new Vector3(-5.0, 3.0, 2.0);
    add(light0);

    var light1 = new DirectionalLight(0xffffff);
    light1.intensity = 0.2;
    light1.specular = new Color.fromHex(0xffffff);
    light1.position = new Vector3(5.0, 3.0, 5.0);
    light1.direction = new Vector3(-1.0, -1.0, 0.0).normalize();
    add(light1);
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
