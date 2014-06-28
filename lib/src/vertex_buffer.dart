part of orange;




class VertexBuffer {
  int offset;
  int stride;
  int type;
  int size;
  bool normalized = false;
  int count;
  int target;
  int usage;
  gl.Buffer buffer;
  TypedData data;
  
  int references = 1;

  VertexBuffer(this.size, this.type, this.stride, this.offset, {this.count: 0, this.data: null, this.target: gl.ARRAY_BUFFER, this.usage: gl.STATIC_DRAW}) {
  }

  enable(gl.RenderingContext ctx, ShaderProperty attrib) {
    bind(ctx);
    ctx.enableVertexAttribArray(attrib.location);
    ctx.vertexAttribPointer(attrib.location, size, type, normalized, stride, offset);
  }

  bind(gl.RenderingContext ctx) {
    if (buffer == null) {
      buffer = ctx.createBuffer();
      ctx.bindBuffer(target, buffer);
      ctx.bufferDataTyped(target, data, usage);
    } else {
      ctx.bindBuffer(target, buffer);
    }
  }
}
