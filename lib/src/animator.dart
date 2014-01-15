part of orange;



class Animator {

  String name;
  Skeleton skeleton;
  Animation animation;
  
  
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
  
  evaluate(Mesh mesh) {
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
    mesh.skeleton._dirtyJoints = true;
    
    
    
  }
}


















