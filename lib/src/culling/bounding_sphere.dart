part of orange;





class BoundingSphere {
  Vector3 center;
  double radius;
  Vector3 centerWorld;
  double radiusWorld;

  Vector3 _tempRadiusVector = new Vector3.zero();

  BoundingSphere(Vector3 minimum, Vector3 maximum) {
    var distance = minimum.distanceTo(maximum);
    center = lerp(minimum, maximum, 0.5);
    radius = distance * 0.5;
    centerWorld = new Vector3.zero();
    _update(new Matrix4.identity());
  }

  // Methods
  void _update(Matrix4 world) {
    centerWorld = world * center;
    _tempRadiusVector = world * new Vector3(1.0, 1.0, 1.0);
    radiusWorld = math.max(math.max(_tempRadiusVector.x.abs(), _tempRadiusVector.y.abs()), _tempRadiusVector.z.abs()) * radius;
  }

  bool isInFrustum(List<Plane> frustumPlanes) {
    for (var i = 0; i < 6; i++) {
      if (frustumPlanes[i].distanceToVector3(centerWorld) <= -radiusWorld) return false;
    }

    return true;
  }

  bool intersectsPoint(Vector3 point) {
    var x = centerWorld.x - point.x;
    var y = centerWorld.y - point.y;
    var z = centerWorld.z - point.z;
    var distance = math.sqrt((x * x) + (y * y) + (z * z));
    if ((radiusWorld - distance).abs() < Director.Epsilon) return false;
    return true;
  }

  static bool intersects(BoundingSphere sphere0, BoundingSphere sphere1) {
    var x = sphere0.centerWorld.x - sphere1.centerWorld.x;
    var y = sphere0.centerWorld.y - sphere1.centerWorld.y;
    var z = sphere0.centerWorld.z - sphere1.centerWorld.z;
    var distance = math.sqrt((x * x) + (y * y) + (z * z));
    if (sphere0.radiusWorld + sphere1.radiusWorld < distance) return false;
    return true;
  }
}
