part of orange;


class Skin {
  Matrix4 bindShapeMatrix;
  List<String> jointsIds;
  MeshAttribute inverseBindMatrices; 
  Map<String, List<Joint>> jointsForSkeleton;

  Map<String, Float32List> matricesForSkeleton;
  
  process(Node node) {
    if(matricesForSkeleton == null) 
      matricesForSkeleton = {};

    var objectSpace = node.matrixWorld.clone();
    objectSpace.invert();
    
    jointsForSkeleton.forEach((skeleton, joints) {
      var matrices = matricesForSkeleton[skeleton];
      if(matrices == null) {
        var length = 16 * jointsIds.length;
        matrices = new Float32List(length);
        matricesForSkeleton[skeleton] = matrices;
        var identity = new Matrix4.identity();
        for(var i = 0; i < length; i++) {
          matrices[i] = identity[i % 16];
        }
      }
      if(inverseBindMatrices != null) {
        var bufferData = inverseBindMatrices.bufferData as Float32List;
        node.meshes.forEach((m) {
          var BSM = bindShapeMatrix;
          var jointsCount = jointsIds.length;
          var IBM = new Matrix4.identity();
          for(var i = 0; i < jointsCount; i++) {
            for(var j = 0; j < 16; j++) {
              IBM[j] = bufferData[(i * 16) + j];
            }
            var JM = joints[i].matrixWorld;
            var destMat = new Matrix4.identity();
            destMat.multiply(objectSpace).multiply(JM).multiply(IBM).multiply(BSM);
            for(var j = 0; j < 16; j++) {
              matrices[(i * 16) + j] = destMat[j];
            }
          }
          m.primitives.forEach((p) => p.jointMatrices = matrices);
        });
      }
    });
  }
}