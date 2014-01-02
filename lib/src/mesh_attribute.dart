part of orange;


class MeshAttribute {
  BufferView bufferView;
  int byteOffset;
  int byteStride;
  int count;
  int type;
  bool normalized;
  List<double> max;
  List<double> min;
  
  gl.Buffer buffer;
  TypedData list;
  
  setupBuffer(gl.RenderingContext ctx) {
    if(buffer == null) {
      if(bufferView.bufferRefs.ready) {
        buffer = ctx.createBuffer();
        ctx.bindBuffer(bufferView.target, buffer);
        list = createTypedData();
        ctx.bufferDataTyped(bufferView.target, list, gl.STATIC_DRAW);
      } else {
        bufferView.bufferRefs.load();
      }
    }
  }

  TypedData createTypedData() {
    var offset = byteOffset + bufferView.byteOffset;
    switch(type) {
      case gl.FLOAT_VEC2:
      case gl.FLOAT_VEC3:
      case gl.FLOAT_VEC4:
      case gl.FLOAT:
        return new Float32List.view(bufferView.bufferRefs.bytes, offset, count * byteStride ~/ 4);
      case gl.UNSIGNED_SHORT:
        return new Uint16List.view(bufferView.bufferRefs.bytes, offset, count);
      default:
        throw new Exception("Not support yet");
    }
  }
}