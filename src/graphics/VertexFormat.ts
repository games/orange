module orange {

  var _typeSize = [];
  _typeSize[ElementType.INT8] = 1;
  _typeSize[ElementType.UINT8] = 1;
  _typeSize[ElementType.INT16] = 2;
  _typeSize[ElementType.UINT16] = 2;
  _typeSize[ElementType.INT32] = 4;
  _typeSize[ElementType.UINT32] = 4;
  _typeSize[ElementType.FLOAT32] = 4;

  export class VertexDescription {
    constructor(
      public name: string,
      public offset: number,
      public stride: number,
      public stream: number,
      public scoptId,
      public dataType,
      public numComponents: number,
      public normalize: boolean,
      public size: number) {}
  }

  export class VertexFormat {

    elements: VertexDescription[];
    hasUv1: boolean;
    hasColor: boolean;
    size: number;

    constructor(graphicsDevice, description: any[]) {
      this.elements = [];
      this.hasUv1 = false;
      this.hasColor = false;

      this.size = 0;
      for (var i = 0, len = description.length; i < len; i++) {
          var elementDesc = description[i];
          var element = new VertexDescription(
                              elementDesc.semantic,
                              0,
                              0,
                              -1,
                              "",
                              elementDesc.type,
                              elementDesc.components,
                              (elementDesc.normalize === undefined) ? false : elementDesc.normalize,
                              elementDesc.components * _typeSize[elementDesc.type]
                            );
          this.elements.push(element);

          this.size += element.size;
          if (elementDesc.semantic === SEMANTIC_TEXCOORD1) {
              this.hasUv1 = true;
          } else if (elementDesc.semantic === SEMANTIC_COLOR) {
              this.hasColor = true;
          }
      }

      var offset = 0;
      for (var i = 0, len = this.elements.length; i < len; i++) {
          var element = this.elements[i];

          element.offset = offset;
          element.stride = this.size;

          offset += element.size;
      }
    }
  }
}
