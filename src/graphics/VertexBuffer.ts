module orange {
  export class  VertexBuffer {
    bufferId: WebGLBuffer;
    numBytes: number;
    storage: ArrayBuffer;

    constructor(public graphicsDevice: GraphicsDevice,
                public format:VertexFormat,
                public numVertices:number,
                public usage:BufferUsage = BufferUsage.STATIC,
                initialData?:ArrayBuffer) {
      this.numBytes = format.size * numVertices;
      this.bufferId = graphicsDevice.gl.createBuffer();
      if (initialData && this.setData(initialData)) {
      } else {
        this.storage = new ArrayBuffer(this.numBytes);
      }
    }

    destory() {
      this.graphicsDevice.gl.deleteBuffer(this.bufferId);
    }

    lock() {
      return this.storage;
    }

    unlock() {
      var gl = this.graphicsDevice.gl;
      var glUsage;
      switch(this.usage) {
        case BufferUsage.STATIC:
          glUsage = gl.STATIC_DRAW;
          break;
        case BufferUsage.DYNAMIC:
          glUsage = gl.DYNAMIC_DRAW;
          break;
        case BufferUsage.STREAM:
          glUsage = gl.STREAM_DRAW;
          break;
      }
      gl.bindBuffer(gl.ARRAY_BUFFER, this.bufferId);
      gl.bufferData(gl.ARRAY_BUFFER, this.storage, glUsage);
    }

    setData(data: ArrayBuffer) {
      if (data.byteLength !== this.numBytes) {
        console.error("VertexBuffer: wrong initial data size: expected " + this.numBytes + ", got " + data.byteLength);
        return false;
      }
      this.storage = data;
      this.unlock();
      return true;
    }
  }
}
