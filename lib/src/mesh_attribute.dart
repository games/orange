part of orange;




class MeshAttribute {
  int offset;
  int stride;
  int type;
  int size;
  bool normalized = false;
  int count;
  
  MeshAttribute(this.size, this.type, this.stride, this.offset, [this.count = 0]);
}