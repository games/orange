part of orange;


class Skeleton {
  List<Joint> roots = new List();
  List<Joint> joints = new List();
  List clips = [];
  List<Matrix4> _jointMatrices = new List();
  List<Matrix4> _invBindMatrices = new List();
  Float32List _invBindMatricesArray;
  Map _subInvBindMatricesArray = new Map();
  
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
  }
    
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
    if(_invBindMatricesArray == null) {
      _invBindMatricesArray = new Float32List(joints.length * 16);
    }
    var cursor = 0;
    for(var i = 0; i < joints.length; i++) {
      var matrixCurrentPose = joints[i].matrixWorld;
      _invBindMatrices[i] = matrixCurrentPose.clone().multiply(_jointMatrices[i]);
      for(var j = 0; j < 16; j++) {
        var arr = _invBindMatrices[i].storage;
        _invBindMatricesArray[cursor++] = arr[j];
      }
    }
  }
  
  getSubInvBindMatrices(meshId, joints) {
    var subArr = _subInvBindMatricesArray[meshId];
    if(subArr == null) {
      subArr = _subInvBindMatricesArray[meshId] = new Float32List(joints.length * 16); 
    }
    var cursor = 0;
    for(var i = 0; i < joints.length; i++) {
      var idx = joints[i];
      for(var j = 0; j < 16; j++) {
        subArr[cursor++] = _invBindMatricesArray[idx * 16 + j];
      }
    }
    return subArr;
  }
  
  setPose(clipIndex) {
    var clip = clips[clipIndex];
    for(var i = 0; i < joints.length; i++) {
      var joint = joints[i];
      var pose = clip.jointPoses[i];
      
      //TODO copy transform of pose to joint
    }
    update();
  }
  
  blendPose(clip1Idx, clip2Idx, weight) {
    var clip1 = clips[clip1Idx];
    var clip2 = clips[clip2Idx];
    for(var i = 0; i < joints.length; i++) {
      var joint = joints[i];
      var pose = clip.jointPoses[i];
      
      joint.position.lerp(clip1.position, clip2.position, weight);
      joint.rotation.slerp(clip1.rotation, clip2.rotation, weight);
      joint.scale.lerp(clip1.scale, clip2.scale, weight);
    }
    update();
  }
}
















