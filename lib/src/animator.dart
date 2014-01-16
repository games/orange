part of orange;



class Animator {
  int version;
  
  String name;
  Skeleton skeleton;
  Animation animation;
  double _duration = 0.0;
  
  evaluate(Mesh mesh, double interval) {
    mesh.skeleton = skeleton;
    
    _duration += interval * 0.001;
    _duration = _duration % animation.length;
    
    animation.tracks.forEach((track) {
      var joint = mesh.skeleton.joints[track.jointId];
      var startframe, endframe;
      for(var i = 0; i < track.keyframes.length - 1; i++) {
        startframe = track.keyframes[i];
        endframe = track.keyframes[i + 1];
        if (endframe.time >= _duration) {
          break;
        }
      }
      
      var percent = (_duration - startframe.time) / (endframe.time - startframe.time);
      var pos = lerp(startframe.translate, endframe.translate, percent);
      var rot = slerp(startframe.rotate, endframe.rotate, percent);
      
      joint._needsUpdateLocalMatrix = false;
      joint._localMatrix = joint.bindPoseMatrix * new Matrix4.zero().fromRotationTranslation(rot, pos);
    });
    mesh.skeleton._dirtyJoints = true;
  }
}


















