part of orange;





class BoundingInfo {
  BoundingBox boundingBox;
  BoundingSphere boundingSphere;

  BoundingInfo(Vector3 minimum, Vector3 maximum) {
    boundingBox = new BoundingBox(minimum, maximum);
    boundingSphere = new BoundingSphere(minimum, maximum);
  }

  void _update(Matrix4 world) {
    boundingBox._update(world);
    boundingSphere._update(world);
  }

  bool isInFrustum(Frustum frustum) {
    if (!boundingSphere.isInFrustum(frustum.planes)) return false;
    return boundingBox.isInFrustum(frustum.planes);
  }

  bool intersectsPoint(Vector3 point) {
    if (this.boundingSphere.centerWorld == null) {
      return false;
    }
    if (!this.boundingSphere.intersectsPoint(point)) {
      return false;
    }
    if (!this.boundingBox.intersectsPoint(point)) {
      return false;
    }
    return true;
  }

  bool intersects(BoundingInfo boundingInfo, bool precise) {
    if (this.boundingSphere.centerWorld == null || boundingInfo.boundingSphere.centerWorld == null) {
      return false;
    }

    if (!BoundingSphere.intersects(this.boundingSphere, boundingInfo.boundingSphere)) {
      return false;
    }

    if (!BoundingBox.intersects(this.boundingBox, boundingInfo.boundingBox)) {
      return false;
    }

    if (!precise) {
      return true;
    }

    var box0 = this.boundingBox;
    var box1 = boundingInfo.boundingBox;
    if (!axisOverlap(box0.directions[0], box0, box1)) return false;
    if (!axisOverlap(box0.directions[1], box0, box1)) return false;
    if (!axisOverlap(box0.directions[2], box0, box1)) return false;
    if (!axisOverlap(box1.directions[0], box0, box1)) return false;
    if (!axisOverlap(box1.directions[1], box0, box1)) return false;
    if (!axisOverlap(box1.directions[2], box0, box1)) return false;
    if (!axisOverlap(box0.directions[0].cross(box1.directions[0]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[0].cross(box1.directions[1]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[0].cross(box1.directions[2]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[1].cross(box1.directions[0]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[1].cross(box1.directions[1]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[1].cross(box1.directions[2]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[2].cross(box1.directions[0]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[2].cross(box1.directions[1]), box0, box1)) return false;
    if (!axisOverlap(box0.directions[2].cross(box1.directions[2]), box0, box1)) return false;
    return true;
  }

  bool axisOverlap(Vector3 axis, BoundingBox box0, BoundingBox box1) {
    var result0 = computeBoxExtents(axis, box0);
    var result1 = computeBoxExtents(axis, box1);
    return extentsOverlap(result0.x, result0.y, result1.x, result1.y);
  }

  Vector2 computeBoxExtents(Vector3 axis, BoundingBox box) {
    var p = box.center.dot(axis);
    var r0 = box.directions[0].dot(axis).abs() * box.extend.x;
    var r1 = box.directions[1].dot(axis).abs() * box.extend.y;
    var r2 = box.directions[2].dot(axis).abs() * box.extend.z;
    var r = r0 + r1 + r2;
    return new Vector2(p - r, p + r);
  }

  bool extentsOverlap(num min0, num max0, num min1, num max1) {
    return !(min0 > max1 || min1 > max0);
  }
}













