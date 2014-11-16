/*
  Orange : Simplified BSD License

  Copyright (c) 2014, Valor Zhong
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
  following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
     disclaimer.
    
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
     following disclaimer in the documentation and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
 */

part of orange;



class Orange {
  static Orange _instance;
  static Orange get instance => _instance;

  factory Orange(html.CanvasElement canvas) {
    if (_instance == null) _instance = new Orange._(canvas);
    return _instance;
  }

  GraphicsDevice _graphicsDevice;
  GraphicsDevice get graphicsDevice => _graphicsDevice;
  
  ResourceManager _resources;
  ResourceManager get resources => _resources;

  GameTime _gameTime;
  GameTime get gameTime => _gameTime;

  Callback initialize;
  Callback1<GameTime> enterFrame;
  Callback exitFrame;

  Node _root;
  Node get root => _root;

  Node _mainCamera;
  Node get mainCamera => _mainCamera;

  Color4 backgroundColor;

  int get width => _graphicsDevice._renderingCanvas.width;
  int get height => _graphicsDevice._renderingCanvas.height;

  Orange._(html.CanvasElement canvas) {
    _graphicsDevice = new GraphicsDevice(canvas);
    _resources = new ResourceManager();
    _gameTime = new GameTime();
    _root = new Node("Root");

    _mainCamera = new Node("MainCamera");
    _mainCamera.addComponent(new PerspectiveCamera(canvas.width / canvas.height));
    _root.addChild(_mainCamera);

    backgroundColor = new Color4(100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0);

    canvas.onResize.listen((e) => _mainCamera.camera.stageResized());
  }

  run() {
    if (initialize != null) initialize();
    //_root.initialize();
    html.window.requestAnimationFrame(_animate);
  }

  void _animate(num highResTime) {
    html.window.requestAnimationFrame(_animate);

    final delta = highResTime - _gameTime.total;
    _gameTime.total = highResTime;
    _gameTime.elapsed = delta;

    if (enterFrame != null) enterFrame(_gameTime);

    _root.update(_gameTime);

    _graphicsDevice.clear(backgroundColor);
    _root.render();

    // physics
    // shadows
    // octree
    // prepare
    // render to target
    // render to stage
    // bounding box
    // particles
    // clear

    if (exitFrame != null) exitFrame();
  }
}
