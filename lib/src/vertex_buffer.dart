part of orange;




class VertexBuffer implements Disposable {
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

  VertexBuffer(this.size, this.type, this.stride, this.offset, {this.count: 0, this.data: null, this.target: gl.ARRAY_BUFFER, this.usage: gl.STATIC_DRAW});

  VertexBuffer.indices(data)
      : size = 0,
        stride = 0,
        offset = 0,
        type = gl.UNSIGNED_SHORT,
        usage = gl.STATIC_DRAW,
        target = gl.ELEMENT_ARRAY_BUFFER {
    if (!(data is Uint16List)) data = new Uint16List.fromList(data);
    count = data.length;
    this.data = data;
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

  void dispose() {
    references--;
    if (references <= 0) {
      Orange.instance.graphicsDevice.ctx.deleteBuffer(buffer);
    }
  }
}
