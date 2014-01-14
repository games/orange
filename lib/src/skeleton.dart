part of orange;



class Skeleton {
  String name;
  String blendMode;
  List<Joint> roots;
  List<Joint> joints;
  Float32List jointMatrices;
  bool _dirtyJoints = true;
  
  buildHierarchy() {
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
      if(jointMatrices == null) {
        jointMatrices = new Float32List(MAX_JOINTS_PER_MESH * 16);
      }
      roots.forEach((joint) => joint.updateMatrix());
      for(var i = 0; i < joints.length; i++) {
        var joint = joints[i];
        var mat = joint.inverseBindMatrix * joint.worldMatrix;
        for(var j = 0; j < 16; j++) {
          jointMatrices[i * 16 + j] = mat[j];
        }
      }
      _dirtyJoints = false;
    }
  }
}