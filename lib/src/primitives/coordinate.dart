part of orange;



class Coordinate extends Mesh {
  
  Coordinate() {
    var arrowX = _createArrow(new Color.fromHex(0xff0000));
    arrowX.rotation.rotateZ(-math.PI / 2);
    add(arrowX);
    
    var arrowY = _createArrow(new Color.fromHex(0x0000ff));
    add(arrowY);
    
    var arrowZ = _createArrow(new Color.fromHex(0x00ff00));
    arrowZ.rotation.rotateX(math.PI / 2);
    add(arrowZ);
  }
  
  Mesh _createArrow(Color color) {
    var arrow = new Mesh();
    
    var material = new Material();
    material.shininess = 64.0;
    material.ambientColor = color;
    material.specularColor = new Color.fromList([0.0, 0.0, 0.0]);
    material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    
    var cone = new Cone(bottomRadius: 0.025, height: 0.1, capSegments: 10);
    cone.position.setValues(0.0, 0.3, 0.0);
    cone.material = material;
    arrow.add(cone);
    
    var axle = new Cylinder(topRadius: 0.01, bottomRadius: 0.01, height: 0.5, capSegments: 3);
    axle.position.setValues(0.0, 0.0, 0.0);
    arrow.add(axle);
    
    return arrow;
  }
  
  
}