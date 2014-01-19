part of orange;



class AnimationController {
  String name;
  Animation _animation;
  Map<String, Animation> animations;
  Mesh _mesh;
  double _duration = 0.0;
  Matrix4 _emptyMatrix = new Matrix4.zero();
  
  AnimationController(this._mesh) {
    _mesh.animator = this;
  }
  
  switchAnimation(String name) {
    _animation = animations[name];
  }
  
  evaluate(double interval) {
    if(_animation == null)
      return;
    var skeleton = _animation.skeleton;
    _duration += interval * 0.001;
    _duration = _duration % _animation.length;
    _animation.tracks.forEach((track) {
      var joint = skeleton.joints[track.jointId];
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
    skeleton._dirtyJoints = true;
    _mesh.skeleton = skeleton;
  }
}


















