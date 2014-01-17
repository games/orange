part of orange;



class AnimationController {
  int version;
  String clipName;
  Mesh mesh;
  Skeleton skeleton;
  Map<String, Clip> clips;
  double _duration = 0.0;
  Matrix4 _emptyMatrix = new Matrix4.zero();
  
  evaluate(double interval) {
    mesh.skeleton = skeleton;
    
    var clip = clips[clipName];
    _duration += interval * 0.001;
    _duration = _duration % clip.length;
    
    clip.tracks.forEach((track) {
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
      joint._localMatrix = joint._bindPoseMatrix * _emptyMatrix.fromRotationTranslation(rot, pos);
    });
    mesh.skeleton._dirtyJoints = true;
  }
}


















