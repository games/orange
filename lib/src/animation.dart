part of orange;



class Animation {
  int version;
  String name;
  int frameRate = 0;
  double duration = 0.0;
  int frameCount = 0;
  Map<String, int> bonesIds;
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
    
    bonesIds = {};
    List bonesDesc = anim["bones"];
    for(var i = 0; i < bonesDesc.length; i++) {
      bonesIds[bonesDesc[i]] = i;
    }
    keyframes = [];
    var ks = anim["keyframes"];
    ks.forEach((frame) {
      var keyframe = new Keyframe();
      frame.forEach((b) {
        var bone = new Bone();
        bone.pos = new Vector3.fromList(b["pos"]);
        bone.rot = new Quaternion.fromList(b["rot"]);
        keyframe.bones.add(bone);
      });
      keyframes.add(keyframe);
    });
  }
  
  evaluate(int frameId, Model model) {
    var bones = model._skeleton.bones;
    if(bones == null) {
      return;
    }
    
    var frame = keyframes[frameId];
    bones.forEach((bone) {
      var boneId = bonesIds[bone.name];
      if(boneId != null) {
        bone.pos = frame.bones[boneId].pos;
        bone.rot = frame.bones[boneId].rot;
      }
      if(bone.parent != -1) {
        var parent = bones[bone.parent];
        bone.worldPos = parent.worldRot.multiplyVec3(bone.pos);
        bone.worldPos = bone.worldPos + parent.worldPos;
        bone.worldRot = parent.worldRot.clone().multiply(bone.rot);
      }
      
      if(bone.skinned) {
        bone.boneMat = new Matrix4.identity().fromRotationTranslation(bone.worldRot, bone.worldPos);
        bone.boneMat.multiply(bone.bindPoseMat);
      }
    });
    
    model._skeleton._dirtyBones = true;
  }
}


















