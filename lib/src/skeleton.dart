part of orange;


class Skeleton {
  List<Joint> _roots = new List();
  List<Joint> joints = new List();
  
  
  updateHierarchy() {
    _roots = [];
    joints.forEach((joint) {
      if(joint.parentIndex >= 0) {
        var parent = joints[joint.parentIndex];
        parent.add(joint);
      } else {
        _roots.add(joint);
      }
    });
  }
  
}
















