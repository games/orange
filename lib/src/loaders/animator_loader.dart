part of orange;



class AnimatorLoader {
  
  Future<Animator> load(String url) {
    var completer = new Completer<Animator>();
    html.HttpRequest.getString(url).then((rsp){
      var json = JSON.decode(rsp);
      var animator = new Animator();
      animator.name = json["name"];
      animator.skeleton = Parser.parseSkeleton(json);
      animator.animation = Parser.parseAnimation(json["animations"][0]);
      completer.complete(animator);
    });
    return completer.future;
  }
  
}