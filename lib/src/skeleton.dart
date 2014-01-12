part of orange;



class Skeleton {
  String name;
  List<Joint> joints;
  Float32List jointMatrices;
  bool _dirtyJoints = true;
  
  update() {
    if(_dirtyJoints) {
      for(var i = 0; i < joints.length; i++) {
        var joint = joints[i];
        for(var j = 0; j < joint.jointMat.storage.length; j++) {
          jointMatrices[i * 16 + j] = joint.jointMat[j];
        }
      }
      _dirtyJoints = false;
    }
  }
  
  Float32List subBoneMatrices(Mesh mesh) => jointMatrices.sublist(mesh.jointOffset * 16, (mesh.jointOffset + mesh.jointCount) * 16);
}