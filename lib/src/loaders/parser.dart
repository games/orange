part of orange;



class Parser {
  
  static parseSkeleton(Map doc) {
    var skeleton = new Skeleton();
    skeleton.joints = [];
    doc["joints"].forEach((j) {
      var joint = new Joint();
      joint.id = j["id"];
      if(j.containsKey("parent")) {
        joint.parentId = j["parent"];
      } else {
        joint.parentId = -1;
      }
      joint.name = j["name"];
      joint.position = new Vector3.fromList(j["position"]);
      joint.rotation = parseRotation(j["rotation"]);
      skeleton.joints.add(joint);
    });
    skeleton.buildHierarchy();
    return skeleton;
  }
  
  static parseClip(Map doc) {
    var clip = new Clip();
    clip.name = doc["name"];
    clip.length = doc["length"].toDouble();
    clip.tracks = [];
    doc["tracks"].forEach((t) {
      var track = new Track();
      track.jointId = t["joint"];
      track.keyframes = [];
      t["keyframes"].forEach((k) {
        var keyframe = new Keyframe();
        keyframe.time = k["time"].toDouble();
        keyframe.rotate = parseRotation(k["rotate"]);
        keyframe.translate = new Vector3.fromList(k["translate"]);
        track.keyframes.add(keyframe);
      });
      clip.tracks.add(track);
    });
    return clip;
  }
  
  static parseRotation(Map rot) => new Quaternion.axisAngle(new Vector3.fromList(rot["axis"]), rot["angle"].toDouble());
  
}
















