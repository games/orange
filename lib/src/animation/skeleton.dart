part of orange;



class Skeleton {
  String name;
  List<Joint> _roots;
  List<Joint> joints;
  Float32List jointMatrices;
  bool _dirtyJoints = true;
  
  Matrix4 _bindShapeMatrix;
  
  buildHierarchy() {
    jointMatrices = new Float32List(joints.length * 16);
    _roots = [];
    joints.forEach((joint) {
      if(joint.parent != null) return;
      if(joint.parentId == -1) {
        _roots.add(joint);
      } else {
        joints[joint.parentId].add(joint);
      }
    });
    _roots.forEach((joint) => joint.updateMatrix());
    if(_bindShapeMatrix == null) _bindShapeMatrix = new Matrix4.identity();
  }
  
  updateMatrix() {
    if(_dirtyJoints) {
      _roots.forEach((joint) => joint.updateMatrix());
      for(var i = 0; i < joints.length; i++) {
        var joint = joints[i];
        var mat = joint.worldMatrix * joint._inverseBindMatrix * _bindShapeMatrix;
        for(var j = 0; j < 16; j++) {
          jointMatrices[i * 16 + j] = mat[j];
        }
      }
      _dirtyJoints = false;
    }
  }
}