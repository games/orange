part of orange;




class Collider {
  Vector3 radius = new Vector3(1.0, 1.0, 1.0);
  int retry = 0;
  Vector3 velocity;
  Vector3 basePoint;
  double epsilon;
  bool collisionFound;
  double velocityWorldLength;
  Vector3 basePointWorld = new Vector3.zero();
  Vector3 velocityWorld = new Vector3.zero();
  Vector3 normalizedVelocity = new Vector3.zero();
  Vector3 initialVelocity;
  Vector3 initialPosition;
  double nearestDistance;
  Vector3 intersectionPoint;
  Mesh collidedMesh;

  Vector3 _collisionPoint = new Vector3.zero();
  Vector3 _planeIntersectionPoint = new Vector3.zero();
  Vector3 _tempVector = new Vector3.zero();
  Vector3 _tempVector2 = new Vector3.zero();
  Vector3 _tempVector3 = new Vector3.zero();
  Vector3 _tempVector4 = new Vector3.zero();
  Vector3 _edge = new Vector3.zero();
  Vector3 _baseToVertex = new Vector3.zero();
  Vector3 _destinationPoint = new Vector3.zero();
  Vector3 _slidePlaneNormal = new Vector3.zero();
  Vector3 _displacementVector = new Vector3.zero();

  void _initialize(Vector3 source, Vector3 dir, double e) {
    velocity = dir;
    normalizedVelocity = dir.normalized();
    basePoint = source;

    basePointWorld = source.multiply(radius);
    velocityWorld = dir.multiply(radius);

    velocityWorldLength = velocityWorld.length;

    epsilon = e;
    collisionFound = false;
  }

  bool _checkPointInTriangle(Vector3 point, Vector3 pa, Vector3 pb, Vector3 pc, Vector3 n) {
    _tempVector = pa - point;
    _tempVector2 = pb - point;
    _tempVector4 = _tempVector.cross(_tempVector2);

    var d = _tempVector4.dot(n);
    if (d < 0) return false;

    _tempVector3 = pc - point;
    _tempVector4 = _tempVector2.cross(_tempVector3);

    d = _tempVector4.dot(n);
    if (d < 0) return false;

    _tempVector4 = _tempVector3.cross(_tempVector);
    d = _tempVector4.dot(n);
    return d >= 0;
  }

  bool _canDoCollision(Vector3 sphereCenter, double sphereRadius, Vector3 vecMin, Vector3 vecMax) {
    var distance = basePointWorld.distanceTo(sphereCenter);
    var max = maxNumber(radius.x, radius.y, radius.z);

    if (distance > velocityWorldLength + max + sphereRadius) {
      return false;
    }

    if (!_intersectBoxAASphere(vecMin, vecMax, basePointWorld, velocityWorldLength + max)) return false;

    return true;
  }

  void _testTriangle(faceIndex, Mesh subMesh, Vector3 p1, Vector3 p2, Vector3 p3) {
    var t0;
    var embeddedInPlane = false;

    if (subMesh._trianglePlanes == null) {
      subMesh._trianglePlanes = [];
    }

    if (!subMesh._trianglePlanes[faceIndex]) {
      subMesh._trianglePlanes[faceIndex] = new Plane.components(0.0, 0.0, 0.0, 0.0);
      subMesh._trianglePlanes[faceIndex].copyFromPoints(p1, p2, p3);
    }

    var trianglePlane = subMesh._trianglePlanes[faceIndex];

    if ((subMesh.material == null) && !trianglePlane.isFrontFacingTo(normalizedVelocity, 0)) return;

    var signedDistToTrianglePlane = trianglePlane.signedDistanceTo(basePoint);
    var normalDotVelocity = trianglePlane.normal.dot(velocity);

    if (normalDotVelocity == 0) {
      if (signedDistToTrianglePlane.abs() >= 1.0) return;
      embeddedInPlane = true;
      t0 = 0;
    } else {
      t0 = (-1.0 - signedDistToTrianglePlane) / normalDotVelocity;
      var t1 = (1.0 - signedDistToTrianglePlane) / normalDotVelocity;

      if (t0 > t1) {
        var temp = t1;
        t1 = t0;
        t0 = temp;
      }

      if (t0 > 1.0 || t1 < 0.0) return;

      if (t0 < 0) t0 = 0;
      if (t0 > 1.0) t0 = 1.0;
    }

    _collisionPoint.setZero();

    var found = false;
    var t = 1.0;

    if (!embeddedInPlane) {
      _planeIntersectionPoint = basePoint - trianglePlane.normal;
      _tempVector = velocity * t0;
      _planeIntersectionPoint.add(_tempVector);

      if (_checkPointInTriangle(_planeIntersectionPoint, p1, p2, p3, trianglePlane.normal)) {
        found = true;
        t = t0;
        _collisionPoint.setFrom(_planeIntersectionPoint);
      }
    }

    if (!found) {
      var velocitySquaredLength = velocity.length2;

      var a = velocitySquaredLength;

      _tempVector = basePoint - p1;
      var b = 2.0 * velocity.dot(_tempVector);
      var c = _tempVector.length2 - 1.0;

      var lowestRoot = _getLowestRoot(a, b, c, t);
      if (lowestRoot["found"]) {
        t = lowestRoot["root"];
        found = true;
        _collisionPoint.setFrom(p1);
      }

      _tempVector = basePoint - p2;
      b = 2.0 * velocity.dot(_tempVector);
      c = _tempVector.length2 - 1.0;

      lowestRoot = _getLowestRoot(a, b, c, t);
      if (lowestRoot["found"]) {
        t = lowestRoot["root"];
        found = true;
        _collisionPoint.setFrom(p2);
      }

      _tempVector = basePoint - p3;
      b = 2.0 * velocity.dot(_tempVector);
      c = _tempVector.length2 - 1.0;

      lowestRoot = _getLowestRoot(a, b, c, t);
      if (lowestRoot["found"]) {
        t = lowestRoot["root"];
        found = true;
        _collisionPoint.setFrom(p3);
      }

      _edge = p2 - p1;
      _baseToVertex = p1 - basePoint;
      var edgeSquaredLength = _edge.length2;
      var edgeDotVelocity = _edge.dot(velocity);
      var edgeDotBaseToVertex = _edge.dot(_baseToVertex);

      a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
      b = edgeSquaredLength * (2.0 * velocity.dot(_baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
      c = edgeSquaredLength * (1.0 - _baseToVertex.length2) + edgeDotBaseToVertex * edgeDotBaseToVertex;

      lowestRoot = _getLowestRoot(a, b, c, t);
      if (lowestRoot["found"]) {
        var f = (edgeDotVelocity * lowestRoot["root"] - edgeDotBaseToVertex) / edgeSquaredLength;

        if (f >= 0.0 && f <= 1.0) {
          t = lowestRoot["root"];
          found = true;
          _edge.scale(f);
          _collisionPoint = p1 + _edge;
        }
      }

      _edge = p3 - p2;
      _baseToVertex = p2 - basePoint;
      edgeSquaredLength = _edge.length2;
      edgeDotVelocity = _edge.dot(velocity);
      edgeDotBaseToVertex = _edge.dot(_baseToVertex);

      a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
      b = edgeSquaredLength * (2.0 * velocity.dot(_baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
      c = edgeSquaredLength * (1.0 - _baseToVertex.length2) + edgeDotBaseToVertex * edgeDotBaseToVertex;
      lowestRoot = _getLowestRoot(a, b, c, t);
      if (lowestRoot["found"]) {
        var f = (edgeDotVelocity * lowestRoot["root"] - edgeDotBaseToVertex) / edgeSquaredLength;

        if (f >= 0.0 && f <= 1.0) {
          t = lowestRoot["root"];
          found = true;
          _edge.scale(f);
          _collisionPoint = p2 + _edge;
        }
      }

      _edge = p1 - p3;
      _baseToVertex = p3 - basePoint;
      edgeSquaredLength = _edge.length2;
      edgeDotVelocity = _edge.dot(velocity);
      edgeDotBaseToVertex = _edge.dot(_baseToVertex);

      a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
      b = edgeSquaredLength * (2.0 * velocity.dot(_baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
      c = edgeSquaredLength * (1.0 - _baseToVertex.length2) + edgeDotBaseToVertex * edgeDotBaseToVertex;

      lowestRoot = _getLowestRoot(a, b, c, t);
      if (lowestRoot["found"]) {
        var f = (edgeDotVelocity * lowestRoot["root"] - edgeDotBaseToVertex) / edgeSquaredLength;

        if (f >= 0.0 && f <= 1.0) {
          t = lowestRoot["root"];
          found = true;
          _edge.scale(f);
          _collisionPoint = p3 + _edge;
        }
      }
    }

    if (found) {
      var distToCollision = t * velocity.length;

      if (!collisionFound || distToCollision < nearestDistance) {
        if (intersectionPoint == null) {
          intersectionPoint = _collisionPoint.clone();
        } else {
          intersectionPoint.setFrom(_collisionPoint);
        }
        nearestDistance = distToCollision;
        collisionFound = true;
        collidedMesh = subMesh;
      }
    }
  }

  void _collide(subMesh, List<Vector3> pts, List<int> indices, int indexStart, int indexEnd, num decal) {
    for (var i = indexStart; i < indexEnd; i += 3) {
      var p1 = pts[indices[i] - decal];
      var p2 = pts[indices[i + 1] - decal];
      var p3 = pts[indices[i + 2] - decal];

      _testTriangle(i, subMesh, p3, p2, p1);
    }
  }

  void _getResponse(Vector3 pos, Vector3 vel) {
    _destinationPoint = pos + vel;
    vel.scale(nearestDistance / vel.length);

    pos = basePoint + vel;

    _slidePlaneNormal = pos - intersectionPoint;
    _slidePlaneNormal.normalize();
    _displacementVector = _slidePlaneNormal.scaled(epsilon);

    pos.add(_displacementVector);
    intersectionPoint.add(_displacementVector);
    
     var d = -intersectionPoint.dot(_slidePlaneNormal) + _destinationPoint.dot(_slidePlaneNormal);
    _slidePlaneNormal.scale(d);

    _destinationPoint.sub(_slidePlaneNormal);
    vel = _destinationPoint - intersectionPoint;
  }

  Map _getLowestRoot(num a, num b, num c, num maxR) {
    var determinant = b * b - 4.0 * a * c;
    var result = {
      "root": 0,
      "found": false
    };

    if (determinant < 0) return result;

    var sqrtD = math.sqrt(determinant);
    var r1 = (-b - sqrtD) / (2.0 * a);
    var r2 = (-b + sqrtD) / (2.0 * a);

    if (r1 > r2) {
      var temp = r2;
      r2 = r1;
      r1 = temp;
    }

    if (r1 > 0 && r1 < maxR) {
      result["root"] = r1;
      result["found"] = true;
      return result;
    }

    if (r2 > 0 && r2 < maxR) {
      result["root"] = r2;
      result["found"] = true;
      return result;
    }

    return result;
  }

  bool _intersectBoxAASphere(Vector3 boxMin, Vector3 boxMax, Vector3 sphereCenter, num sphereRadius) {
    if (boxMin.x > sphereCenter.x + sphereRadius) return false;
    if (sphereCenter.x - sphereRadius > boxMax.x) return false;
    if (boxMin.y > sphereCenter.y + sphereRadius) return false;
    if (sphereCenter.y - sphereRadius > boxMax.y) return false;
    if (boxMin.z > sphereCenter.z + sphereRadius) return false;
    if (sphereCenter.z - sphereRadius > boxMax.z) return false;
    return true;
  }
}

