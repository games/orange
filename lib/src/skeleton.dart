part of orange;



class Skeleton {
  String name;
  String blendMode;
  List<Joint> roots;
  List<Joint> joints;
  Float32List jointMatrices;
  bool _dirtyJoints = true;
  
  updateHierarchy() {
    roots = [];
    joints.forEach((joint) {
      if(joint.parentId == -1) {
        roots.add(joint);
      } else {
        joints[joint.parentId].add(joint);
      }
    });
  }
  
  updateMatrix() {
    if(_dirtyJoints) {
      if(jointMatrices == null) {
        jointMatrices = new Float32List(MAX_BONES_PER_MESH * 16);
      }
      roots.forEach((joint) => joint.updateMatrix());
      for(var i = 0; i < joints.length; i++) {
        var joint = joints[i];
        var len = joint.worldMatrix.storage.length;
        for(var j = 0; j < len; j++) {
          jointMatrices[i * 16 + j] = joint.worldMatrix[j];
        }
      }
      _dirtyJoints = false;
    }
  }
}