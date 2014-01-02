part of orange;


class Shader {
  String path;
  String source;
  
  OnlyOnce _loadTask;
  
  Shader() {
    _loadTask = new OnlyOnce(() {
      html.HttpRequest.getString(path).then((rsp) => source = rsp);
    });
  }
  
  load() => _loadTask.execute();
  
  bool get ready => source != null;
}