part of orange;




class BufferView {
  int offset;
  int stride;
  int type;
  int size;
  bool normalized = false;
  int count;
  int target;
  TypedData data;
  gl.Buffer buffer;
  
  BufferView(this.size, this.type, this.stride, this.offset,
      {int count: 0, TypedData data: null, int target: gl.ARRAY_BUFFER}) {
    this.count = count;
    this.data = data;
    this.target = target;
  }
  
  bindBuffer(gl.RenderingContext ctx) {
    if(buffer == null) {
      buffer = ctx.createBuffer();
      ctx.bindBuffer(target, buffer);
      ctx.bufferDataTyped(target, data, gl.STATIC_DRAW);
    } else {
      ctx.bindBuffer(target, buffer);
    }
  }
}