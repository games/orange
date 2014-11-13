// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

  GameTime _gameTime;
  GameTime get gameTime => _gameTime;

  Callback initialize;
  Callback enterFrame;
  Callback exitFrame;
  
  Node _root;
  Node get root => _root;
  
  Color backgroundColor;

  Orange._(html.CanvasElement canvas) {
    _graphicsDevice = new GraphicsDevice(canvas);
    _gameTime = new GameTime();
    _root = new Node("Root");
    backgroundColor = new Color(100.0, 149.0, 237.0, 255.0);
    
    if(initialize != null) initialize();
    
    _root.initialize();
  }

  run() => html.window.requestAnimationFrame(_animate);

  void _animate(num highResTime) {
    run();

    final delta = highResTime - _gameTime.total;
    _gameTime.total = highResTime;
    _gameTime.elapsed = delta;

    if (enterFrame != null) enterFrame();
    
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
