module orange {
  export class  VertexBuffer {
    bufferId: WebGLBuffer;
    glFormat: number;
    bytesPerIndex: number;
    storage: ArrayBuffer;

    constructor(public graphicsDevice: GraphicsDevice,
                public format:VertexFormat,
                public numVertices:number,
                public usage:BufferUsage = BufferUsage.STATIC,
                initialData?:ArrayBuffer) {

      var gl = graphicsDevice.gl;

      this.bufferId = gl.createBuffer();

      var bytesPerIndex;
      if (format == IndexFormat.UINT8) {
        bytesPerIndex = 1;
        this.glFormat = gl.UNSIGNED_BYTE;
      } else if (format == IndexFormat.UINT16) {
        bytesPerIndex = 2;
        this.glFormat = gl.UNSIGNED_SHORT;
      } else if (format == IndexFormat.UINT32) {
        bytesPerIndex = 4;
        this.glFormat = gl.UNSIGNED_INT;
      }
      this.bytesPerIndex = bytesPerIndex;
      this.storage = new ArrayBuffer(this.numIndices * bytesPerIndex);
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
      gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufferId);
      gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.storage, glUsage);
    }
  }
}
