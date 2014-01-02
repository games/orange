part of orange;


class Buffer {
  String path;
  int byteLength;
  String type;
  ByteBuffer bytes;
  
  OnlyOnce _loadTask;
  
  Buffer() {
    _loadTask = new OnlyOnce(() {
      html.HttpRequest.request(path, responseType: "arraybuffer").then((r){
        bytes = r.response;
      });
    });
  }
  
  load() => _loadTask.execute();
  
  bool get ready => bytes != null;
}