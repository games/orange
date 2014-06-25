part of orange;



class PlaneMesh extends PolygonMesh {

  PlaneMesh({String name, num width: 1.0, num height: 1.0, int subdivisions: 1, bool ground: false})
      : super(name: name) {

    var vertices = [];
    var texcoords = [];
    var faces = [];

    for (var row = 0; row <= subdivisions; row++) {
      for (var col = 0; col <= subdivisions; col++) {
        var px = (col * width) / subdivisions - (width / 2);
        var yorz = ((subdivisions - row) * height) / subdivisions - (height / 2.0);
        var py = ground ? 0.0 : yorz;
        var pz = ground ? yorz : 0.0;
        vertices.addAll([px.toDouble(), py, -pz.toDouble()]);
        texcoords.addAll([col / subdivisions, 1.0 - row / subdivisions]);
      }
    }
    for (var row = 0; row < subdivisions; row++) {
      for (var col = 0; col < subdivisions; col++) {
        faces.add(col + 1 + (row + 1) * (subdivisions + 1));
        faces.add(col + 1 + row * (subdivisions + 1));
        faces.add(col + row * (subdivisions + 1));

        faces.add(col + (row + 1) * (subdivisions + 1));
        faces.add(col + 1 + (row + 1) * (subdivisions + 1));
        faces.add(col + row * (subdivisions + 1));
      }
    }

    setPositions(vertices);
    setTexCoords(texcoords);
    setIndices(faces);
    calculateSurfaceNormals();
  }


  PlaneMesh.fromHightMap(String url, {String name, num width: 1.0, num height: 1.0, num minHeight, num maxHeight, int subdivisions: 1}) : super(name: name) {
    var img = new html.ImageElement(src: url);
    img.onLoad.listen((_) {
      var canvas = new html.CanvasElement();
      var ctx = canvas.getContext("2d");
      var mw = img.width;
      var mh = img.height;
      canvas.width = mw;
      canvas.height = mh;
      ctx.drawImage(img, 0, 0);
      var buffer = ctx.getImageData(0, 0, mw, mh);
      _createFromHightMap(width, height, subdivisions, minHeight, maxHeight, buffer, mw, mh);
    });
  }

  _createFromHightMap(num width, num height, int subdivisions, num minHeight, num maxHeight, html.ImageData imageData, int bufferWidth, int bufferHeight) {
    var buffer = imageData.data;
    var indices = [];
    var positions = [];
    var uvs = [];
    var row, col;

    // Vertices
    for (row = 0; row <= subdivisions; row++) {
      for (col = 0; col <= subdivisions; col++) {
        var position = new Vector3((col * width) / subdivisions - (width / 2.0), 0.0, ((subdivisions - row) * height) / subdivisions - (height / 2.0));

        // Compute height
        var heightMapX = (((position.x + width / 2) / width) * (bufferWidth - 1)).toInt() | 0;
        var heightMapY = ((1.0 - (position.z + height / 2) / height) * (bufferHeight - 1)).toInt() | 0;

        var pos = (heightMapX + heightMapY * bufferWidth) * 4;
        var r = buffer[pos] / 255.0;
        var g = buffer[pos + 1] / 255.0;
        var b = buffer[pos + 2] / 255.0;

        var gradient = r * 0.3 + g * 0.59 + b * 0.11;

        position.y = minHeight + (maxHeight - minHeight) * gradient;

        // Add  vertex
        positions.addAll([position.x, position.y, -position.z]);
        uvs.addAll([col / subdivisions, 1.0 - row / subdivisions]);
      }
    }

    // Indices
    for (row = 0; row < subdivisions; row++) {
      for (col = 0; col < subdivisions; col++) {
        indices.add(col + 1 + (row + 1) * (subdivisions + 1));
        indices.add(col + 1 + row * (subdivisions + 1));
        indices.add(col + row * (subdivisions + 1));

        indices.add(col + (row + 1) * (subdivisions + 1));
        indices.add(col + 1 + (row + 1) * (subdivisions + 1));
        indices.add(col + row * (subdivisions + 1));
      }
    }

    setPositions(positions);
    setTexCoords(uvs);
    setIndices(indices);
    calculateSurfaceNormals();
  }
}



