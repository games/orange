part of orange;


class Renderer {
  html.CanvasElement _canvas;
  gl.RenderingContext ctx;
  int _lastMaxEnabledArray = -1;
  
  Renderer(this._canvas) {
    ctx = _canvas.getContext3d(preserveDrawingBuffer: true);
    ctx.enable(gl.DEPTH_TEST);
    ctx.frontFace(gl.CCW);
    ctx.cullFace(gl.BACK);
    ctx.enable(gl.CULL_FACE);
  }
  
  prepare() {
    ctx.viewport(0, 0, _canvas.width, _canvas.height);
    ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }
  
  render(Scene scene) {
    ctx.clearColor(scene.backgroundColor.red, scene.backgroundColor.green, scene.backgroundColor.blue, scene.backgroundColor.alpha);
    scene.camera.updateMatrixWorld();
    scene.nodes.forEach((node) {
      node.updateMatrixWorld();
      _renderNode(scene, node);
    });
  }
  
  _renderNode(Scene scene, Node node) {
    var camera = scene.camera;
    node.meshes.forEach((mesh) {
      mesh.primitives.forEach((primitive) {
        if(primitive.ready) {
          var material = primitive.material;
//          material = new ColorMaterial(new Color.fromHex(0x0000ff));
          var technique = material.technique;
          technique = techniqueForTextureMaterial;
          var pass = technique.passes[material.technique.pass];
          var program = pass.program;
          program.build(ctx);
          
          if(program.ready) {
            ctx.useProgram(program.program);
            var blending = 0;
            var depthTest = 1;
            var depthMask = 1;
            var cullFaceEnable = 1;
            var blendEquation = gl.FUNC_ADD;
            var sfactor = gl.SRC_ALPHA;
            var dfactor = gl.ONE_MINUS_SRC_ALPHA;
            if(pass.states != null) {
              if(pass.states["blendEnable"] != null)
                blending = pass.states["blendEnable"];
              if(pass.states["depthTestEnable"] != null)
                depthTest = pass.states["depthTestEnable"];
              if(pass.states["depthMask"] != null)
                depthMask = pass.states["depthMask"];
              if(pass.states["cullFaceEnable"] != null)
                cullFaceEnable = pass.states["cullFaceEnable"];
              if(pass.states["blendEquation"] != null) {
                var blendFunc = pass.states["blendFunc"];
                if(blendFunc != null) {
                  if(blendFunc["sfactor"] != null) sfactor = blendFunc["sfactor"];
                  if(blendFunc["dfactor"] != null) dfactor = blendFunc["dfactor"]; 
                }
              }
            }
            setState(gl.DEPTH_TEST, depthTest != 0);
            setState(gl.CULL_FACE, cullFaceEnable != 0);
            ctx.enable(gl.SAMPLE_ALPHA_TO_COVERAGE);
            ctx.depthMask(depthMask == 1);
            
            setState(gl.BLEND, blending != 0);
            if(blending > 0) {
              ctx.blendEquation(blendEquation);
              ctx.blendFunc(sfactor, dfactor);
            }
            var globalIntensity = 1;
            var transparency = technique.parameters["transparency"];
            if(transparency != null && transparency["value"] != null) {
              globalIntensity *= transparency["value"];
            }
            var filterColor = technique.parameters["filterColor"];
            if(filterColor != null && filterColor["value"] != null) {
              globalIntensity *= filterColor["value"][3];
            }
            if(globalIntensity < 0.00001)
              return;
            if(globalIntensity < 1 && blending == 0) {
              setState(gl.BLEND, true);
              ctx.blendEquation(gl.FUNC_ADD);
              ctx.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
            }
            
            var currentTexture = 0;
            var newMaxEnabledArray = -1;
            // bind uniforms
            program.uniformSymbols.forEach((symbol) {
              var value;
              var parameterName = pass.instanceProgram["uniforms"][symbol];
              var parameter = technique.parameters[parameterName];
              if(parameter != null) {
                var semantic = parameter["semantic"];
                if(semantic != null) {
                  if(semantic == "PROJECTION") {
                    value = camera.projectionMatrix;
                  } else if (semantic == "MODELVIEW") {
                    value = camera.matrixWorld * node.matrixWorld;
                  } else if (semantic == "MODELVIEWINVERSETRANSPOSE") {
                    value = (camera.matrixWorld * node.matrixWorld).normalMatrix3();
                  }
                }
              }
              if(value == null && parameter != null) {
                // find the node be named {source}
                if(parameter["source"] != null) {
                  var node = scene.resources[parameter["source"]];
                  value = node.matrixWorld;
                } else if(parameter["value"] != null) {
                  value = parameter["value"];
                } else {
                  value = material.instanceTechnique["values"][parameterName];
                }
              }
              
              if(value != null) {
                var type = program.getTypeForSymbol(symbol);
                if(type == gl.SAMPLER_CUBE || type == gl.SAMPLER_2D) {
                  Texture texture = scene.resources[value];
                  if(texture.ready) {
                    ctx.activeTexture(gl.TEXTURE0 + currentTexture);
                    ctx.bindTexture(texture.target, texture.texture);
                    var location = program.symbolToLocation[symbol];
                    if(location != null) {
                      program.setValueForSymbol(ctx, symbol, currentTexture);
                      currentTexture++;
                    }
                  } else {
                    texture.setup(ctx);
                  }
                } else {
                  program.setValueForSymbol(ctx, symbol, value);
                }
              }
            });     
            
            // bind attributes
            var attributes = pass.instanceProgram["attributes"];
            program.attributeSymbols.forEach((symbol) {
              var parameter = technique.parameters[attributes[symbol]];
              var semantic = parameter["semantic"];
              
              var accessor = primitive.attributes[semantic];
              
              ctx.bindBuffer(accessor.bufferView.target, accessor.buffer);
              var location = program.symbolToLocation[symbol];
              if(location != null) {
                if(location > newMaxEnabledArray) {
                  newMaxEnabledArray = location;
                }
                ctx.enableVertexAttribArray(location);
                ctx.vertexAttribPointer(location, accessor.byteStride ~/ 4, gl.FLOAT, false, 0, 0);
              }
            });
            
            for(var i = (newMaxEnabledArray + 1); i < _lastMaxEnabledArray; i++) {
              ctx.disableVertexAttribArray(i);              
            }
            _lastMaxEnabledArray = newMaxEnabledArray;
            
            ctx.bindBuffer(primitive.indices.bufferView.target, primitive.indices.buffer);
            ctx.drawElements(primitive.primitive, primitive.indices.count, primitive.indices.type, 0);
            
            if(globalIntensity < 1 && blending == 0) {
              setState(gl.BLEND, false);
            }
          }
        } else {
          primitive.setupBuffer(ctx);
        }
      });
    });
    node.children.forEach((n) => _renderNode(scene, n));
  }
  
  
  
  
  
  
  setState(int cap, bool enable) {
    if(enable) 
      ctx.enable(cap);
    else
      ctx.disable(cap);
  }
}







