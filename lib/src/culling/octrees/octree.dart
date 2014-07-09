part of orange;


abstract class OctreeContainer<T> {
  List<OctreeBlock<T>> blocks;
}


class Octree<T> implements OctreeContainer {

  List<OctreeBlock<T>> blocks;
  List<T> dynamicContent = [];

  int maxBlockCapacity;
  int maxDepth;
  List<T> _selectionContent;
  OctreeBlockCreation<T> _blockCreation;
  
  List<T> get selectionContent => _selectionContent;

  Octree(this._blockCreation, {this.maxBlockCapacity: 64, this.maxDepth: 2}) {
    _selectionContent = new List();
  }

  void update(Vector3 worldMin, Vector3 worldMax, List<T> entries) {
    _createBlocks(worldMin, worldMax, entries, maxBlockCapacity, 0, maxDepth, this, _blockCreation);
  }

  void addMesh(T entry) {
    blocks.forEach((block) => block.addEntry(entry));
  }

  List<T> select(List<Plane> frustumPlanes, [bool allowDuplicate = false]) {
    _selectionContent.clear();
    blocks.forEach((block) => block.select(frustumPlanes, _selectionContent, allowDuplicate));
    _addTo(allowDuplicate);
    return _selectionContent;
  }

  List<T> intersects(Vector3 sphereCenter, num sphereRadius, [bool allowDuplicate = false]) {
    _selectionContent.clear();
    blocks.forEach((block) => block.intersects(sphereCenter, sphereRadius, _selectionContent, allowDuplicate));
    _addTo(allowDuplicate);
    return _selectionContent;
  }

  List<T> intersectsRay(Ray ray) {
    _selectionContent.clear();
    blocks.forEach((block) => block.intersectsRay(ray, _selectionContent));
    _addTo(false);
    return _selectionContent;
  }

  void _addTo([bool allowDuplicate = false]) {
    if (allowDuplicate) {
      _selectionContent.addAll(dynamicContent);
    } else {
      dynamicContent.forEach((entry) {
        if (!_selectionContent.contains(entry)) {
          _selectionContent.add(entry);
        }
      });
    }
  }

  static void _createBlocks(Vector3 worldMin, Vector3 worldMax, List entries, int maxBlockCapacity, int currentDepth, int maxDepth, OctreeContainer target, OctreeBlockCreation creation) {
    target.blocks = [];
    var blockSize = new Vector3((worldMax.x - worldMin.x) / 2, (worldMax.y - worldMin.y) / 2, (worldMax.z - worldMin.z) / 2);
    // Segmenting space
    for (var x = 0; x < 2; x++) {
      for (var y = 0; y < 2; y++) {
        for (var z = 0; z < 2; z++) {
          var localMin = worldMin + new Vector3(blockSize.x * x, blockSize.y * y, blockSize.z * z);
          var localMax = worldMin + new Vector3(blockSize.x * (x + 1.0), blockSize.y * (y + 1.0), blockSize.z * (z + 1.0));
          var block = new OctreeBlock(localMin, localMax, maxBlockCapacity, currentDepth + 1, maxDepth, creation);
          block.addEntries(entries);
          target.blocks.add(block);
        }
      }
    }
  }

  static OctreeBlockCreation<Mesh> MeshesBlockCreation = (Mesh entry, OctreeBlock<Mesh> block) {
    if (entry.boundingInfo != null && entry.boundingInfo.boundingBox.intersectsMinMax(block.minPoint, block.maxPoint)) {
      block.entries.add(entry);
    }
  };
}
