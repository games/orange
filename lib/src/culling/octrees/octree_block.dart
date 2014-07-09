part of orange;




typedef void OctreeBlockCreation<T>(T entry, OctreeBlock<T> block);


class OctreeBlock<T> implements OctreeContainer {
  List<T> entries = [];
  List<OctreeBlock<T>> blocks;

  int depth;
  int maxDepth;
  int capacity;
  Vector3 minPoint;
  Vector3 maxPoint;
  BoundingBox _boundingBox;
  OctreeBlockCreation<T> _blockCreation;

  OctreeBlock(this.minPoint, this.maxPoint, this.capacity, this.depth, this.maxDepth, this._blockCreation) {
    _boundingBox = new BoundingBox(minPoint, maxPoint);
  }

  void addEntry(T entry) {
    if (blocks != null) {
      blocks.forEach((block) => block.addEntry(entry));
      return;
    }
    _blockCreation(entry, this);
    if (entries.length > capacity && depth < maxDepth) {
      createInnerBlocks();
    }
  }

  void addEntries(List<T> entries) {
    entries.forEach((entry) => addEntry(entry));
  }

  void select(List<Plane> frustumPlanes, List<T> selection, [bool allowDuplicate = false]) {
    if (_boundingBox.isInFrustum(frustumPlanes)) {
      if (blocks != null) {
        blocks.forEach((block) => block.select(frustumPlanes, selection, allowDuplicate));
        return;
      }
      _addTo(selection, allowDuplicate);
    }
  }

  void intersects(Vector3 sphereCenter, num sphereRadius, List<T> selection, [bool allowDuplicate = false]) {
    if (BoundingBox.IntersectsSphere(minPoint, maxPoint, sphereCenter, sphereRadius)) {
      if (blocks != null) {
        blocks.forEach((block) => block.intersects(sphereCenter, sphereRadius, selection, allowDuplicate));
        return;
      }
      _addTo(selection, allowDuplicate);
    }
  }

  void intersectsRay(Ray ray, List<T> selection) {
    if (ray.intersectsWithAabb3(new Aabb3.minMax(minPoint, maxPoint)) != null) {
      if (blocks != null) {
        blocks.forEach((block) => block.intersectsRay(ray, selection));
        return;
      }
      _addTo(selection);
    }
  }

  void _addTo(List<T> selection, [bool allowDuplicate = false]) {
    if (allowDuplicate) {
      selection.addAll(entries);
    } else {
      entries.forEach((entry) {
        if (!selection.contains(entry)) {
          selection.add(entry);
        }
      });
    }
  }

  void createInnerBlocks() {
    Octree._createBlocks(minPoint, maxPoint, this.entries, capacity, depth, maxDepth, this, _blockCreation);
  }
}



