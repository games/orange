part of orange;



class Skeleton {
  String name;
  List<Joint> roots;
  List<Joint> joints;
  Float32List jointMatrices;
  bool _dirtyJoints = true;
  
  buildHierarchy() {
    jointMatrices = new Float32List(joints.length * 16);
    roots = [];
    joints.forEach((joint) {
      if(joint.parentId == -1) {
        roots.add(joint);
      } else {
        joints[joint.parentId].add(joint);
      }
    });
    roots.forEach((joint) => joint.updateMatrix());
  }
  
  updateMatrix() {
    if(_dirtyJoints) {
      roots.forEach((joint) => joint.updateMatrix());
      for(var i = 0; i < joints.length; i++) {
        var joint = joints[i];
        var mat = joint.worldMatrix * joint._inverseBindMatrix;
        for(var j = 0; j < 16; j++) {
          jointMatrices[i * 16 + j] = mat[j];
        }
      }
      _dirtyJoints = false;
    }
  }
}