part of orange;



class Animator {

  String name;
  Skeleton skeleton;
  Animation animation;
  
  int frameId = 0;
  
  int version;
  int frameRate = 0;
  double duration = 0.0;
  int frameCount = 0;
  Map<String, int> jointsIds;
  List<Keyframe> keyframes;
  bool complete = false;
  
//  _parseAnimation(Map anim) {
//    name = anim["name"];
//    version = anim["animVersion"];
//    frameRate = anim["frameRate"];
//    duration = anim["duration"].toDouble();
//    frameCount = anim["frameCount"];
//    
//    jointsIds = {};
//    List jointDesc = anim["bones"];
//    for(var i = 0; i < jointDesc.length; i++) {
//      jointsIds[jointDesc[i]] = i;
//    }
//    keyframes = [];
//    var ks = anim["keyframes"];
//    ks.forEach((frame) {
//      var keyframe = new Keyframe();
//      frame.forEach((b) {
//        var joint = new Joint();
//        joint.position = new Vector3.fromList(b["pos"]);
//        joint.rotation = new Quaternion.fromList(b["rot"]);
//        keyframe.joints.add(joint);
//      });
//      keyframes.add(keyframe);
//    });
//  }
  
  evaluate(Mesh mesh, double interval) {
//    if(node.skeleton == null)
//      return;
//    
//    var joints = node.skeleton.joints;
//    var frame = keyframes[frameId];
//    joints.forEach((joint) {
//      var jointId = jointsIds[joint.name];
//      if(jointId != null) {
//        joint.position = frame.joints[jointId].position;
//        joint.rotation = frame.joints[jointId].rotation;
//      }
//      if(joint.parentId != -1) {
//        var parent = joints[joint.parentId];
//        joint.worldPos = parent.worldRot.multiplyVec3(joint.pos);
//        joint.worldPos = joint.worldPos + parent.worldPos;
//        joint.worldRot = parent.worldRot.clone().multiply(joint.rot);
//      }
//      
//      if(joint.skinned) {
//        joint.jointMat = new Matrix4.identity().fromRotationTranslation(joint.worldRot, joint.worldPos);
//        joint.jointMat.multiply(joint.bindPoseMat);
//      }
//    });
    
//    node.skeleton._dirtyJoints = true;
    
    mesh.skeleton = skeleton;
    
    duration += interval * 0.001;
    duration = duration % animation.length;
    
    animation.tracks.forEach((track) {
      var joint = mesh.skeleton.joints[track.jointId];
      var startframe, endframe, i;
      for(i = 0; i < track.keyframes.length - 1; i++) {
        startframe = track.keyframes[i];
        endframe = track.keyframes[i + 1];
        if (endframe.time >= duration) {
          break;
        }
      }
      
      i = 3;
      startframe = track.keyframes[i];
      endframe = track.keyframes[i + 1];
      
      var percent = 0.0;//(duration - startframe.time) / (endframe.time - startframe.time);
      var pos = lerp(startframe.translate, endframe.translate, percent);
      var rot = slerp(startframe.rotate, endframe.rotate, percent);
      
      joint._needsUpdateLocalMatrix = false;
      joint._localMatrix = joint.bindPoseMatrix * new Matrix4.zero().fromRotationTranslation(rot, pos);
      
      
      
      
     
//      joint.rotation = rot.clone().multiply(joint.originRot);
//      joint.position = joint.originPos + rot.multiplyVec3(pos);
//      joint.rotation = joint.originRot.clone().multiply(rot);
//      joint.position = joint.originPos + pos;
      
//      if(joint.parent != null) {
//        var parent = joint.parent;
//        joint.position = parent.rotation.multiplyVec3(pos);
//        joint.position = joint.position + parent.position;
//        joint.rotation = parent.rotation.clone().multiply(rot);
//      }
      
      
      
//      joint.rotation = joint.originRot.clone();
//      joint.position = joint.originPos.clone();
//      
//      for(i = 0; i < track.keyframes.length - 1; i++) {
//        startframe = track.keyframes[i];
//        endframe = track.keyframes[i + 1];
//        
//        var percent = (duration - startframe.time) / (endframe.time - startframe.time);
//        var pos = lerp(startframe.translate, endframe.translate, percent);
//        var rot = slerp(startframe.rotate, endframe.rotate, percent);
//        joint.rotation.multiply(rot);
////        joint.position.add(pos);
//        if(duration < endframe.time) {
//          break;
//        }
//      }
      
      
//      joint.rotation = startframe.rotate.clone().multiply(joint.originRot);
//      joint.position = startframe.translate.clone().add(joint.originPos);
      
//      joint._dirtyLocalMatrix = false;
//      joint._localMatrix = joint.bindPoseMatrix.clone();
//      joint._localMatrix.translate(pos);
//      joint._localMatrix.rotate(rot.radians, rot.axis);
      
      
//      if(joint.parent != null) {
//        var parent = joint.parent;
//        joint.worldPos = parent.worldRot.multiplyVec3(joint.position);
//        joint.worldPos = joint.worldPos + parent.worldPos;
//        joint.worldRot = parent.worldRot.clone().multiply(joint.rotation);
//      }

      
//      joint.position = joint.bindPostMatrix * lerp(startframe.translate, endframe.translate, percent);
//      joint.rotation = joint.bindPostMatrix * slerp(startframe.rotate, endframe.rotate, percent);
    });
    mesh.skeleton._dirtyJoints = true;
  }
}


















