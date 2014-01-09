part of orange;



class Skeleton {
  List<Joint> joints;
  Float32List jointMatrices;
  bool _dirtyJoints = true;
  
  update() {
    if(_dirtyJoints) {
      for(var i = 0; i < joints.length; i++) {
        var bone = joints[i];
        for(var j = 0; j < bone.jointMat.storage.length; j++) {
          jointMatrices[i * 16 + j] = bone.jointMat[j];
        }
      }
      _dirtyJoints = false;
    }
  }
  
  Float32List subBoneMatrices(Mesh mesh) => jointMatrices.sublist(mesh.jointOffset * 16, (mesh.jointOffset + mesh.jointCount) * 16);
}