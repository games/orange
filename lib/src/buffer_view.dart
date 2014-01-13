part of orange;




class BufferView {
  int offset;
  int stride;
  int type;
  int size;
  bool normalized = false;
  int count;
  gl.Buffer buffer;
  
  BufferView(this.size, this.type, this.stride, this.offset, [this.count = 0, this.buffer = null]);
}