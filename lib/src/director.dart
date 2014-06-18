part of orange;




class Director {

  Renderer2 renderer;
  Scene _scene;
  num _lastElapsed = 0.0;

  Director(this.renderer);

  replace(Scene scene) {
    if (_scene != null) {
      _scene.exit();
    }
    scene.director = this;
    scene.enter();
    _scene = scene;
  }

  run() => html.window.requestAnimationFrame(_animate);

  _animate(num elapsed) {
    run();
    final interval = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (_scene != null) {
//      _scene.nodes.forEach((node) {
//        if (node is Mesh && node.animator != null) node.animator.evaluate(interval);
//      });
      _scene.update(elapsed, interval);
      renderer.prepare();
      renderer.render(_scene);
    }
  }

}
