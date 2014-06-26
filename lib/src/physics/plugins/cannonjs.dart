part of orange;



class CannonMesh {
  Mesh mesh;
  JS.JsObject body;
  JS.JsObject material;
  CannonMesh(this.mesh, this.body, this.material);
}


class CannonJSPlugin implements PhysicsEnginePlugin {

  JS.JsObject _world;
  List<CannonMesh> _registeredMeshes = [];
  List _physicsMaterials = [];

  @override
  initialize([int iterations = 10]) {
    var cannon = JS.context["CANNON"];
    _world = new JS.JsObject(cannon["World"]);
    _world["broadphase"] = new JS.JsObject(cannon["NaiveBroadphase"]);

    var solver = new JS.JsObject(cannon["GSSolver"]);
    solver["iterations"] = iterations;
    _world["solver"] = solver;
  }

  num _checkWithEpsilon(num val) {
    if (val < PhysicsEngine.Epsilon) return PhysicsEngine.Epsilon;
    return val;
  }

  @override
  void applyImpulse(Mesh mesh, Vector3 force, Vector3 contactPoint) {
    var worldPos = _cannonVec3(contactPoint.x, contactPoint.z, contactPoint.y);
    var impulse = _cannonVec3(force.x, force.z, force.y);
    _registeredMeshes.forEach((CannonMesh rm) {
      if (rm.mesh == mesh) {
        rm.body.callMethod("applyImpulse", [impulse, worldPos]);
      }
    });
  }

  @override
  bool createLink(Mesh mesh1, Mesh mesh2, Vector3 pivot1, Vector3 pivot2) {
    var body1 = null,
        body2 = null;
    _registeredMeshes.forEach((CannonMesh rm) {
      if (rm.mesh == mesh1) {
        body1 = rm.body;
      } else if (rm.mesh == mesh2) {
        body2 = rm.body;
      }
    });
    if (body1 == null || body2 == null) {
      return false;
    }
    var cannon = JS.context["CANNON"];
    var v1 = _cannonVec3(pivot1.x, pivot1.z, pivot1.y);
    var v2 = _cannonVec3(pivot2.x, pivot2.z, pivot2.y);
    var constraint = new JS.JsObject(cannon["PointToPointConstraint"], [body1, v1, body2, v2]);
    _world.callMethod("addConstraint", [constraint]);
    return true;
  }

  @override
  void runOneStep(double delta) {
    _world.callMethod("step", [delta]);
    _registeredMeshes.forEach((CannonMesh mesh) {
      var pos = mesh.body["position"];
      mesh.mesh.setTranslation(pos["x"].toDouble(), pos["z"].toDouble(), pos["y"].toDouble());
      var rot = mesh.body["quaternion"];
      mesh.mesh.setQuaternion(rot["x"].toDouble(), rot["z"].toDouble(), rot["y"].toDouble(), -rot["w"].toDouble());
    });
  }

  @override
  registerMesh(Mesh mesh, int impostor, [PhysicsBodyCreationOptions options]) {
    unregisterMesh(mesh);
    mesh.updateMatrix();
    switch (impostor) {
      case PhysicsEngine.SphereImpostor:
        var bbox = mesh.boundingInfo.boundingBox;
        var radiusX = bbox.maximumWorld.x - bbox.minimumWorld.x;
        var radiusY = bbox.maximumWorld.y - bbox.minimumWorld.y;
        var radiusZ = bbox.maximumWorld.z - bbox.minimumWorld.z;
        return _createSphere(math.max(math.max(_checkWithEpsilon(radiusX), _checkWithEpsilon(radiusY)), _checkWithEpsilon(radiusZ)) / 2, mesh, options);
      case PhysicsEngine.BoxImpostor:
        var bbox = mesh.boundingInfo.boundingBox;
        var min = bbox.minimumWorld;
        var max = bbox.maximumWorld;
        var box = (max - min).scale(0.5);
        return _createBox(this._checkWithEpsilon(box.x), this._checkWithEpsilon(box.y), this._checkWithEpsilon(box.z), mesh, options);
      case PhysicsEngine.PlaneImpostor:
        return _createPlane(mesh, options);
      case PhysicsEngine.MeshImpostor:
        var rawVerts = mesh.geometry.buffers[Semantics.position];
        var rawFaces = mesh.indices;
        return _createConvexPolyhedron(rawVerts, rawFaces, mesh, options);
    }
    return null;
  }

  _createConvexPolyhedron(VertexBuffer rawVerts, VertexBuffer rawFaces, Mesh mesh, [PhysicsBodyCreationOptions options]) {
    // TODO
    return null;
  }

  _createBox(num x, num y, num z, Mesh mesh, [PhysicsBodyCreationOptions options]) {
    var shape = new JS.JsObject(JS.context["CANNON"]["Box"], [_cannonVec3(x, z, y)]);
    if (options == null) return shape;
    return _createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
  }

  _createSphere(double radius, Mesh mesh, [PhysicsBodyCreationOptions options]) {
    var shape = new JS.JsObject(JS.context["CANNON"]["Sphere"], [radius]);
    if (options == null) return shape;
    return _createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
  }

  _createPlane(Mesh mesh, [PhysicsBodyCreationOptions options]) {
    var shape = new JS.JsObject(JS.context["CANNON"]["Plane"]);
    if (options == null) return shape;
    return _createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
  }

  @override
  registerMeshesAsCompound(List<PhysicsCompoundBodyPart> parts, PhysicsBodyCreationOptions options) {
    var cannon = JS.context["CANNON"];
    var compoundShape = new JS.JsObject(cannon["Compound"]);
    var i = 0;
    parts.forEach((PhysicsCompoundBodyPart part) {
      var mesh = part.mesh;
      var shape = registerMesh(mesh, part.impostor);
      if (i == 0) {
        compoundShape.callMethod("addChild", [shape, _cannonVec3(0, 0, 0)]);
      } else {
        compoundShape.callMethod("addChild", [shape, _cannonVec3(mesh.position.x, mesh.position.z, mesh.position.y)]);
      }
      i++;
    });
    var initialMesh = parts[0].mesh;
    var body = _createRigidBodyFromShape(compoundShape, initialMesh, options.mass, options.friction, options.restitution);
    body.parts = parts;
    return body;
  }

  _createRigidBodyFromShape(JS.JsObject shape, Mesh mesh, double mass, double friction, double restitution) {
    var cannon = JS.context["CANNON"];
    Quaternion initialRotation = null;
    if (mesh._rotation != null) {
      initialRotation = mesh._rotation.clone();
      mesh._rotation = new Quaternion.identity();
    }
    var material = _addMaterial(friction, restitution);
    var body = new JS.JsObject(cannon["RigidBody"], [mass, shape, material]);
    if (initialRotation != null) {
      body["quaternion"]["x"] = initialRotation.x;
      body["quaternion"]["y"] = initialRotation.z;
      body["quaternion"]["z"] = initialRotation.y;
      body["quaternion"]["w"] = -initialRotation.w;
    }
    var wordPos = mesh.worldMatrix.getTranslation();
    body["position"].callMethod("set", [wordPos.x, wordPos.z, wordPos.y]);
    _world.callMethod("add", [body]);
    _registeredMeshes.add(new CannonMesh(mesh, body, material));
    return body;
  }

  _addMaterial(double friction, double restitution) {
    var cannon = JS.context["CANNON"];
    var index;
    var mat;
    for (index = 0; index < _physicsMaterials.length; index++) {
      mat = _physicsMaterials[index];
      if (mat["friction"] == friction && mat["restitution"] == restitution) {
        return mat;
      }
    }
    var currentMat = new JS.JsObject(cannon["Material"]);
    currentMat["friction"] = friction;
    currentMat["restitution"] = restitution;
    _physicsMaterials.add(currentMat);
    for (index = 0; index < _physicsMaterials.length; index++) {
      mat = _physicsMaterials[index];
      var contactMaterial = new JS.JsObject(cannon["ContactMaterial"], [mat, currentMat, mat["friction"] * currentMat["friction"], mat["restitution"] * currentMat["restitution"]]);
      contactMaterial["contactEquationStiffness"] = 1e10;
      contactMaterial["contactEquationRegularizationTime"] = 10;
      _world.callMethod("addContactMaterial", [contactMaterial]);
    }
    return currentMat;
  }

  @override
  void setGravity(Vector3 gravity) {
    _world["gravity"].callMethod("set", [gravity.x, gravity.z, gravity.y]);
  }

  @override
  unregisterMesh(Mesh mesh) {
    for (var index = 0; index < _registeredMeshes.length; index++) {
      var registeredMesh = _registeredMeshes[index];
      if (registeredMesh.mesh == mesh) {
        // Remove body
        if (registeredMesh.body != null) {
          _world.callMethod("remove", [registeredMesh.body]);
          _unbindBody(registeredMesh.body);
        }
        _registeredMeshes.remove(registeredMesh);
        return;
      }
    }
  }

  _unbindBody(JS.JsObject body) {
    _registeredMeshes.forEach((CannonMesh mesh) {
      if (mesh.body == body) mesh.body = null;
    });
  }

  @override
  void dispose() {
    while (_registeredMeshes.length > 0) {
      unregisterMesh(_registeredMeshes[0].mesh);
    }
  }

  @override
  bool get supported => JS.context.hasProperty("CANNON");
}

JS.JsObject _cannonVec3(num x, num y, num z) {
  return new JS.JsObject(JS.context["CANNON"]["Vec3"], [x, y, z]);
}
