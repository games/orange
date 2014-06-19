part of orange;





class CannonJSPlugin implements PhysicsEnginePlugin {

  JS.JsObject _world;
  List<Mesh> _registeredMeshes = [];
  List _physicsMaterials = [];

  @override
  initialize([int iterations = 10]) {
    var cannon = JS.context["CANNON"];
    _world = new JS.JsObject(cannon["World"]);
    _world["broadphase"] = new JS.JsObject(cannon["NaiveBroadphase"]);
    _world["solver"]["iterations"] = iterations;
  }

  num _checkWithEpsilon(num val) {
    if (val < PhysicsEngine.Epsilon) return PhysicsEngine.Epsilon;
    return val;
  }

  @override
  void applyImpulse(Mesh mesh, Vector3 force, Vector3 contactPoint) {
    // TODO: implement applyImpulse
  }

  @override
  bool createLink(Mesh mesh1, Mesh mesh2, Vector3 pivot1, Vector3 pivot2) {
    // TODO: implement createLink
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  registerMesh(Mesh mesh, int impostor, PhysicsBodyCreationOptions options) {
    unregisterMesh(mesh);
    mesh.updateMatrix();
    switch (impostor) {
      case PhysicsEngine.SphereImpostor:
        break;
      case PhysicsEngine.BoxImpostor:
        break;
      case PhysicsEngine.PlaneImpostor:
        break;
      case PhysicsEngine.MeshImpostor:
        break;
    }
  }

  @override
  registerMeshesAsCompound(List<PhysicsCompoundBodyPart> parts, PhysicsBodyCreationOptions options) {
    // TODO: implement registerMeshesAsCompound
  }

  @override
  void runOneStep(double delta) {
    _world.callMethod("step", [delta]);
    _registeredMeshes.forEach((mesh) {
      mesh.position.x = mesh.body.position.x;
      mesh.position.y = mesh.body.position.y;
      mesh.position.z = mesh.body.position.z;
      if (mesh.rotation == null) {
        mesh.rotation = new Quaternion.identity();
      }
      mesh.rotation.x = mesh.body.quaternion.x;
      mesh.rotation.y = mesh.body.quaternion.z;
      mesh.rotation.z = mesh.body.quaternion.y;
      mesh.rotation.w = -mesh.body.quaternion.w;
    });
  }

  @override
  void setGravity(Vector3 gravity) {
    _world["gravity"].callMethod("set", gravity.storage);
  }

  @override
  unregisterMesh(Mesh mesh) {
    // TODO: implement unregisterMesh
  }

  // TODO: implement supported
  @override
  bool get supported => true;
}
