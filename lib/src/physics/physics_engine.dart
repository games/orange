part of orange;





class PhysicsEngine {
  static const int NoImpostor = 0;
  static const int SphereImpostor = 1;
  static const int BoxImpostor = 2;
  static const int PlaneImpostor = 3;
  static const int CompoundImpostor = 4;
  static const int MeshImpostor = 4;
  static const double Epsilon = 0.001;

  Vector3 gravity;
  PhysicsEnginePlugin _plugin;
  PhysicsEngine([PhysicsEnginePlugin plugin]) {
    if (plugin == null) _plugin = new CannonJSPlugin(); else _plugin = plugin;
  }

  bool get supported => _plugin.supported;

  void _initialize([Vector3 gravity]) {
    _plugin.initialize();
    _setGravity(gravity);
  }

  void _setGravity(Vector3 gravity) {
    if (gravity == null) gravity = new Vector3(0.0, -9.82, 0.0);
    _plugin.setGravity(gravity);
  }

  void _applyImpulse(Mesh mesh, Vector3 force, Vector3 contactPoint) {
    _plugin.applyImpulse(mesh, force, contactPoint);
  }

  bool _createLink(Mesh mesh1, Mesh mesh2, Vector3 pivot1, Vector3 pivot2) {
    return _plugin.createLink(mesh1, mesh2, pivot1, pivot2);
  }

  void dispose() {
    _plugin.dispose();
  }

  _registerMesh(Mesh mesh, int impostor, PhysicsBodyCreationOptions options) {
    _plugin.registerMesh(mesh, impostor, options);
  }

  _registerMeshesAsCompound(List<PhysicsCompoundBodyPart> parts, PhysicsBodyCreationOptions options) {
    _plugin.registerMeshesAsCompound(parts, options);
  }

  void _runOneStep(double delta) {
    if (delta > 0.1) delta = 0.1; else if (delta <= 0.0) delta = 1.0 / 60.0;
    _plugin.runOneStep(delta);
  }

  _unregisterMesh(Mesh mesh) {
    _plugin.unregisterMesh(mesh);
  }
}


abstract class PhysicsEnginePlugin {
  initialize([int iterations = 10]);
  void setGravity(Vector3 gravity);
  void runOneStep(double delta);
  registerMesh(mesh, int impostor, PhysicsBodyCreationOptions options);
  registerMeshesAsCompound(List<PhysicsCompoundBodyPart> parts, PhysicsBodyCreationOptions options);
  unregisterMesh(mesh);
  void applyImpulse(Mesh mesh, Vector3 force, Vector3 contactPoint);
  bool createLink(Mesh mesh1, Mesh mesh2, Vector3 pivot1, Vector3 pivot2);
  void dispose();
  bool get supported;
}

class PhysicsBodyCreationOptions {
  double mass;
  double friction;
  double restitution;
  PhysicsBodyCreationOptions({this.mass: 0.0, this.friction: 0.2, this.restitution: 0.9});
}

abstract class PhysicsCompoundBodyPart {
  Mesh mesh;
  int impostor;
}
