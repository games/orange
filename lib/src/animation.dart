part of orange;



class Animation {
  int version;
  String name;
  int frameRate = 0;
  double duration = 0.0;
  int frameCount = 0;
  Map<String, int> jointsIds;
  List<Keyframe> keyframes;
  bool complete = false;
  
  Future<Animation> load(String url) {
    var completer = new Completer<Animation>();
    html.HttpRequest.request("$url.wglanim").then((r){
      var anim = JSON.decode(r.responseText);
      _parseAnimation(anim);
      completer.complete(this);
    });
    return completer.future;
  }
  
  _parseAnimation(Map anim) {
    name = anim["name"];
    version = anim["animVersion"];
    frameRate = anim["frameRate"];
    duration = anim["duration"].toDouble();
    frameCount = anim["frameCount"];
    
    jointsIds = {};
    List jointDesc = anim["bones"];
    for(var i = 0; i < jointDesc.length; i++) {
      jointsIds[jointDesc[i]] = i;
    }
    keyframes = [];
    var ks = anim["keyframes"];
    ks.forEach((frame) {
      var keyframe = new Keyframe();
      frame.forEach((b) {
        var joint = new Joint();
        joint.pos = new Vector3.fromList(b["pos"]);
        joint.rot = new Quaternion.fromList(b["rot"]);
        keyframe.joints.add(joint);
      });
      keyframes.add(keyframe);
    });
  }
  
  evaluate(int frameId, Node node) {
    if(node.skeleton == null)
      return;
    
    var joints = node.skeleton.joints;
    var frame = keyframes[frameId];
    joints.forEach((joint) {
      var jointId = jointsIds[joint.name];
      if(jointId != null) {
        joint.pos = frame.joints[jointId].pos;
        joint.rot = frame.joints[jointId].rot;
      }
      if(joint.parent != -1) {
        var parent = joints[joint.parent];
        joint.worldPos = parent.worldRot.multiplyVec3(joint.pos);
        joint.worldPos = joint.worldPos + parent.worldPos;
        joint.worldRot = parent.worldRot.clone().multiply(joint.rot);
      }
      
      if(joint.skinned) {
        joint.jointMat = new Matrix4.identity().fromRotationTranslation(joint.worldRot, joint.worldPos);
        joint.jointMat.multiply(joint.bindPoseMat);
      }
    });
    
    node.skeleton._dirtyJoints = true;
  }
}


















