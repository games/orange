part of orange;





class ParticleSystem implements Renderer, Disposable {

  static const BLENDMODE_ONEONE = 0;
  static const BLENDMODE_STANDARD = 1;

  String id;
  int renderingGroupId = 0;
  int blendMod = BLENDMODE_ONEONE;
  bool forceDepthWrite = false;

  // Node or Vector3
  dynamic emitter;
  num emitRate = 10;
  int manualEmitCount = -1;
  double updateSpeed = 0.01;
  double targetStopDuration = 0.0;
  bool disposeOnStop = false;
  double minEmitPower = 1.0;
  double maxEmitPower = 1.0;
  double minLifeTime = 1.0;
  double maxLifeTime = 1.0;
  double minSize = 1.0;
  double maxSize = 1.0;
  double minAngularSpeed = 0.0;
  double maxAngularSpeed = 0.0;
  Texture particleTexture;

  Vector3 gravity = new Vector3.zero();
  Vector3 direction1 = new Vector3(0.0, 1.0, 0.0);
  Vector3 direction2 = new Vector3(0.0, 1.0, 0.0);
  Vector3 minEmitBox = new Vector3(-0.5, -0.5, -0.5);
  Vector3 maxEmitBox = new Vector3(0.5, 0.5, 0.5);
  Color color1 = new Color.float(1.0, 1.0, 1.0, 1.0);
  Color color2 = new Color.float(1.0, 1.0, 1.0, 1.0);
  Color colorDead = new Color(0, 0, 0, 1.0);
  Color textureMask = new Color.float(1.0, 1.0, 1.0, 1.0);

  // TODO typedef
  dynamic startDirectionFunction;
  dynamic startPositionFunction;

  List<Particle> particles = [];

  int _capacity;
  Scene _scene;
  List _vertexDeclaration = [3, 4, 4];
  int _vertexStrideSize = 11 * 4; // 11 floats per particle (x, y, z, r, g, b, a, angle, size, offsetX, offsetY)
  List<Particle> _stockParticles = [];
  num _newPartsExcess = 0;
  gl.Buffer _vertexBuffer;
  VertexBuffer _indexBuffer;
  Float32List _vertices;
  Pass _pass;
  String _cachedDefines;

  Color _scaledColorStep = new Color(0, 0, 0, 0.0);
  Color _colorDiff = new Color(0, 0, 0, 0.0);
  Vector3 _scaledDirection = new Vector3.zero();
  Vector3 _scaledGravity = new Vector3.zero();
  int _currentRenderId = -1;

  bool _alive;
  bool _started = false;
  bool _stopped = false;
  double _actualFrame = 0.0;
  double _scaledUpdateSpeed;

  ParticleSystem(this.id, this._capacity, this._scene) {
    _scene._particleSystemds.add(this);

    var device = _scene.graphicsDevice;
    _vertexBuffer = device.createDynamicVertexBuffer(_capacity * _vertexStrideSize * 4);

    var indices = [];
    var index = 0;
    for (var count = 0; count < _capacity; count++) {
      indices.add(index);
      indices.add(index + 1);
      indices.add(index + 2);
      indices.add(index);
      indices.add(index + 2);
      indices.add(index + 3);
      index += 4;
    }
    _indexBuffer = new VertexBuffer.indices(indices);

    _vertices = new Float32List(_capacity * _vertexStrideSize);

    // Default behaviors
    var _tmp = new Vector3.zero();
    startDirectionFunction = (double emitPower, Matrix4 worldMatrix, Vector3 directionToUpdate) {
      _tmp.x = randomFloat(direction1.x, direction2.x) * emitPower;
      _tmp.y = randomFloat(direction1.y, direction2.y) * emitPower;
      _tmp.z = randomFloat(direction1.z, direction2.z) * emitPower;
      (worldMatrix * _tmp).copyInto(directionToUpdate);
    };


    startPositionFunction = (Matrix4 worldMatrix, Vector3 positionToUpdate) {
      _tmp.x = randomFloat(minEmitBox.x, maxEmitBox.x);
      _tmp.y = randomFloat(minEmitBox.y, maxEmitBox.y);
      _tmp.z = randomFloat(minEmitBox.z, maxEmitBox.z);
      (worldMatrix * _tmp).copyInto(positionToUpdate);
    };
  }

  int get capacity => _capacity;
  bool get alive => _alive;
  bool get stared => _started;

  void start() {
    _started = true;
    _stopped = false;
    _actualFrame = 0.0;
  }

  void stop() {
    _stopped = true;
  }

  void _appendParticleVertex(int index, Particle particle, double offsetX, double offsetY) {
    var offset = index * 11;
    _vertices[offset] = particle.position.x;
    _vertices[offset + 1] = particle.position.y;
    _vertices[offset + 2] = particle.position.z;
    _vertices[offset + 3] = particle.color.red;
    _vertices[offset + 4] = particle.color.green;
    _vertices[offset + 5] = particle.color.blue;
    _vertices[offset + 6] = particle.color.alpha;
    _vertices[offset + 7] = particle.angle;
    _vertices[offset + 8] = particle.size;
    _vertices[offset + 9] = offsetX;
    _vertices[offset + 10] = offsetY;
  }

  void _update(int newParticles) {
    // Update current
    _alive = particles.length > 0;
    for (var index = 0; index < particles.length; index++) {
      var particle = particles[index];
      particle.age += _scaledUpdateSpeed;

      if (particle.age >= particle.lifeTime) {
        _stockParticles.add(particles.removeAt(index));
        index--;
        continue;
      } else {
        particle.colorStep.scaleTo(_scaledUpdateSpeed, _scaledColorStep);
        particle.color.add(_scaledColorStep);

        if (particle.color.alpha < 0) particle.color.alpha = 0.0;
        particle.angle += particle.angularSpeed * _scaledUpdateSpeed;
        particle.direction.copyInto(_scaledDirection).scale(_scaledUpdateSpeed);
        particle.position.add(_scaledDirection);

        gravity.copyInto(_scaledGravity).scale(_scaledUpdateSpeed);
        particle.direction.add(_scaledGravity);
      }
    }

    // Add new ones
    var worldMatrix;

    if (emitter.position != null) {
      worldMatrix = emitter.worldMatrix;
    } else {
      worldMatrix = new Matrix4.translation(emitter);
    }

    for (var index = 0; index < newParticles; index++) {
      if (particles.length == _capacity) {
        break;
      }

      Particle particle;
      if (_stockParticles.length != 0) {
        particle = _stockParticles.removeLast();
        particle.age = 0.0;
      } else {
        particle = new Particle();
      }
      particles.add(particle);

      var emitPower = randomFloat(minEmitPower, maxEmitPower);

      startDirectionFunction(emitPower, worldMatrix, particle.direction);

      particle.lifeTime = randomFloat(minLifeTime, maxLifeTime);

      particle.size = randomFloat(minSize, maxSize);
      particle.angularSpeed = randomFloat(minAngularSpeed, maxAngularSpeed);

      startPositionFunction(worldMatrix, particle.position);

      var step = randomFloat(0, 1.0);
      Color.lerpToRef(color1, color2, step, particle.color);
      colorDead.subtractTo(particle.color, _colorDiff);
      _colorDiff.scaleTo(1.0 / particle.lifeTime, particle.colorStep);
    }
  }

  Pass get pass {
    var define = [];
    if (_scene.clipPlane != null) {
      define.add("#define CLIPPLANE");
    }
    var join = define.join("\n");
    if (_cachedDefines != join) {
      _cachedDefines = join;
      _pass = new Pass();
      _pass.shader = new Shader(_scene.graphicsDevice.ctx, PARTICLES_VS, PARTICLES_FS, common: join);
    }
    return _pass;
  }

  void animate() {
    if (!_started || emitter == null || particleTexture == null || !particleTexture.ready) return;

    if (!pass.shader.ready) return;

    _scaledUpdateSpeed = updateSpeed * _scene.animationRatio;

    var emitCout;
    if (manualEmitCount > -1) {
      emitCout = manualEmitCount;
      manualEmitCount = 0;
    } else {
      emitCout = emitRate;
    }

    var newParticles = ((emitCout * _scaledUpdateSpeed).toInt() >> 0);
    _newPartsExcess += emitCout * _scaledUpdateSpeed - newParticles;

    if (_newPartsExcess > 1.0) {
      newParticles += _newPartsExcess.toInt() >> 0;
      _newPartsExcess -= _newPartsExcess.toInt() >> 0;
    }

    _alive = false;

    if (!_stopped) {
      _actualFrame += _scaledUpdateSpeed;
      if (targetStopDuration > 0 && _actualFrame >= targetStopDuration) {
        stop();
      }
    } else {
      newParticles = 0;
    }

    _update(newParticles);

    if (_stopped) {
      if (!_alive) {
        _started = false;
        if (disposeOnStop) {
          _scene._shouldDisposes.add(this);
        }
      }
    }

    var offset = 0;
    for (var index = 0; index < particles.length; index++) {
      var particle = particles[index];
      _appendParticleVertex(offset++, particle, 0.0, 0.0);
      _appendParticleVertex(offset++, particle, 1.0, 0.0);
      _appendParticleVertex(offset++, particle, 1.0, 1.0);
      _appendParticleVertex(offset++, particle, 0.0, 1.0);
    }

    _scene.graphicsDevice.updateDynamicVertexBuffer(_vertexBuffer, _vertices);
  }

  void render(Scene scene, Matrix4 viewMatrix, Matrix4 viewProjectionMatrix, Matrix4 projectionMatrix, Vector3 eyePosition) {
    if (emitter == null || particleTexture == null || !particleTexture.ready || particles.length == 0) return;

    var pass = this.pass;
    var device = _scene.graphicsDevice;

    device.use(pass);

    if (blendMod == BLENDMODE_ONEONE) {
      device.alphaMode = Orange.ALPHA_ADD;
    } else {
      device.alphaMode = Orange.ALPHA_COMBINE;
    }
    if (forceDepthWrite) {
      device.depthWrite = true;
    }

    device.bindTexture("diffuseSampler", particleTexture);
    device.bindMatrix4("view", viewMatrix);
    device.bindMatrix4("projection", projectionMatrix);
    device.bindColor4("textureMask", textureMask);

    if (scene.clipPlane != null) {
      var clipPlane = scene.clipPlane;
      var invView = viewMatrix.clone();
      invView.invert();
      device.bindMatrix4("invView", invView);
      device.bindFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.constant);
    }

    device.ctx.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    var offset = 0;
    pass.shader.attributes.forEach((String name, ShaderProperty attri) {
      device.ctx.enableVertexAttribArray(attri.location);
      if (name == Semantics.position) {
        device.ctx.vertexAttribPointer(attri.location, 3, gl.FLOAT, false, _vertexStrideSize, offset);
        offset += 3 * 4;
      } else if (name == Semantics.color) {
        device.ctx.vertexAttribPointer(attri.location, 4, gl.FLOAT, false, _vertexStrideSize, offset);
        offset += 4 * 4;
      } else if (name == "options") {
        device.ctx.vertexAttribPointer(attri.location, 4, gl.FLOAT, false, _vertexStrideSize, offset);
        offset += 4 * 4;
      }
    });

    _indexBuffer.bind(device.ctx);
    device.ctx.drawElements(gl.TRIANGLES, _indexBuffer.count, _indexBuffer.type, _indexBuffer.offset);
    device.alphaMode = Orange.ALPHA_DISABLE;



  }

  void dispose() {
    _scene.graphicsDevice.ctx.deleteBuffer(_vertexBuffer);
    _vertexBuffer = null;
    _indexBuffer.dispose();
    _indexBuffer = null;
    if (particleTexture != null) {
      particleTexture.dispose();
      particleTexture = null;
    }
    _scene._particleSystemds.remove(this);
  }

}































