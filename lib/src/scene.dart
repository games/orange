part of orange;


class Scene {
  List<Node> nodes = [];
  bool lightsEnabled = true;
  List<Light> lights = [];
  
  Director director;
  PerspectiveCamera camera;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  
  Scene(this.camera);
  
  enter() {
    
  }
  
  update(num elapsed, num interval) {
    
  }
  
  exit() {
    
  }
}