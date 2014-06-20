part of orange;





class BoundingBox {
  List<Vector3> vectors = [];
  Vector3 center;
  Vector3 extend;
  List<Vector3> directions;
  List<Vector3> vectorsWorld;
  Vector3 minimumWorld;
  Vector3 maximumWorld;

  Matrix4 _worldMatrix;

  BoundingBox(Vector3 minimum, Vector3 maximum) {
    // Bounding vectors
    vectors.add(minimum.clone());
    vectors.add(maximum.clone());

    vectors.add(minimum.clone());
    vectors[2].x = maximum.x;

    vectors.add(minimum.clone());
    vectors[3].y = maximum.y;

    vectors.add(minimum.clone());
    vectors[4].z = maximum.z;

    vectors.add(maximum.clone());
    vectors[5].z = minimum.z;

    vectors.add(maximum.clone());
    vectors[6].x = minimum.x;

    vectors.add(maximum.clone());
    vectors[7].y = minimum.y;

    // OBB
    center = (maximum + minimum).scale(0.5);
    extend = (maximum - minimum).scale(0.5);
    directions = [new Vector3.zero(), new Vector3.zero(), new Vector3.zero()];

    // World
    vectorsWorld = [];
    for (var index = 0; index < vectors.length; index++) {
      vectorsWorld.add(new Vector3.zero());
    }
    minimumWorld = new Vector3.zero();
    maximumWorld = new Vector3.zero();

    _update(new Matrix4.identity());
  }

  // Methods
  Matrix4 get worldMatrix => _worldMatrix;


  void _update(Matrix4 world) {
    minimumWorld = new Vector3.all(double.MAX_FINITE);
    maximumWorld = new Vector3.all(-double.MAX_FINITE);

    for (var index = 0; index < vectors.length; index++) {
      var v = vectorsWorld[index];
      (world * vectors[index] as Vector3).copyInto(v);


      if (v.x < minimumWorld.x) minimumWorld.x = v.x;
      if (v.y < minimumWorld.y) minimumWorld.y = v.y;
      if (v.z < minimumWorld.z) minimumWorld.z = v.z;

      if (v.x > maximumWorld.x) maximumWorld.x = v.x;
      if (v.y > maximumWorld.y) maximumWorld.y = v.y;
      if (v.z > maximumWorld.z) maximumWorld.z = v.z;
    }

    // OBB
    center = maximumWorld + minimumWorld;
    center.scale(0.5);

    directions[0].copyFromArray(world.storage);
    directions[1].copyFromArray(world.storage, 4);
    directions[2].copyFromArray(world.storage, 8);

    _worldMatrix = world;
  }

  bool isInFrustum(List<Plane> frustumPlanes) {
    return BoundingBox.IsInFrustum(vectorsWorld, frustumPlanes);
  }

  bool intersectsPoint(Vector3 point) {
    var delta = Director.Epsilon;
    if (maximumWorld.x - point.x < delta || delta > point.x - minimumWorld.x) return false;
    if (maximumWorld.y - point.y < delta || delta > point.y - minimumWorld.y) return false;
    if (maximumWorld.z - point.z < delta || delta > point.z - minimumWorld.z) return false;
    return true;
  }

  bool intersectsSphere(BoundingSphere sphere) {
    return BoundingBox.IntersectsSphere(minimumWorld, maximumWorld, sphere.centerWorld, sphere.radiusWorld);
  }

  bool intersectsMinMax(Vector3 min, Vector3 max) {
    if (maximumWorld.x < min.x || minimumWorld.x > max.x) return false;
    if (maximumWorld.y < min.y || minimumWorld.y > max.y) return false;
    if (maximumWorld.z < min.z || minimumWorld.z > max.z) return false;
    return true;
  }

  // Statics
  static bool intersects(BoundingBox box0, BoundingBox box1) {
    if (box0.maximumWorld.x < box1.minimumWorld.x || box0.minimumWorld.x > box1.maximumWorld.x) return false;
    if (box0.maximumWorld.y < box1.minimumWorld.y || box0.minimumWorld.y > box1.maximumWorld.y) return false;
    if (box0.maximumWorld.z < box1.minimumWorld.z || box0.minimumWorld.z > box1.maximumWorld.z) return false;
    return true;
  }

  static bool IntersectsSphere(Vector3 minPoint, Vector3 maxPoint, Vector3 sphereCenter, num sphereRadius) {
    var vector = clamp(sphereCenter, minPoint, maxPoint);
    var num = sphereCenter.distanceToSquared(vector);
    return (num <= (sphereRadius * sphereRadius));
  }

  static bool IsInFrustum(List<Vector3> boundingVectors, List<Plane> frustumPlanes) {
    for (var p = 0; p < 6; p++) {
      var inCount = 8;

      for (var i = 0; i < 8; i++) {
        if (frustumPlanes[p].distanceToVector3(boundingVectors[i]) < 0) {
          --inCount;
        } else {
          break;
        }
      }
      if (inCount == 0) return false;
    }
    return true;
  }
}
