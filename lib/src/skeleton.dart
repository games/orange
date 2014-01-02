part of orange;


class Skeleton {
  List<Joint> roots = new List();
  List<Joint> joints = new List();
  List<Matrix4> _jointMatrices = new List();
  List<Matrix4> _invBindMatrices = new List();
  List<Matrix4> _invBindMatricesArray = new List();
  Map _subInvBindMatricesArray;
  
  updateHierarchy() {
    roots = [];
    joints.forEach((joint) {
      if(joint.parentIndex >= 0) {
        var parent = joints[joint.parentIndex];
        parent.add(joint);
      } else {
        roots.add(joint);
      }
    });
    
    updateJointMatrices() {
      roots.forEach((joint) => joint.updateMatrixWorld());
      for(var i = 0; i < joints.length; i ++) {
        var joint = joints[i];
        var m = joint.matrixWorld.clone();
        m.invert();
        _jointMatrices[i] = m;
        _invBindMatrices[i] = new Matrix4.identity();
      }
    }
    
    update() {
      roots.forEach((joint) => joint.updateMatrixWorld());
      
    }
  }
}
















