part of orange;



class AnimatorLoader {
  
  Future<AnimationController> load(String url) {
    var completer = new Completer<AnimationController>();
    html.HttpRequest.getString(url).then((rsp){
      var json = JSON.decode(rsp);
      var animator = new AnimationController();
      animator.name = json["name"];
      animator.skeleton = Parser.parseSkeleton(json);
      animator.animation = Parser.parseClip(json["animations"][0]);
      completer.complete(animator);
    });
    return completer.future;
  }
  
}