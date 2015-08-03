module orange {
  export class Scene {
    root;
    drawCalls;
    immediateDrawCalls;
    shadowCasters;

    depthDrawCalls = 0;
    shadowDrawCalls = 0;
    forwardDrawCalls =0;

    flog;
    fogColor;
    fogStart;
    fogEnd;
    fogDensity;

    ambientLight;

    exposure = 1.0;
    private gammaCorrection;
    private toneMapping = 0;

    private skyboxPrefiltered128;
    private skyboxPrefiltered64;
    private skyboxPrefiltered32;
    private skyboxPrefiltered16;
    private skyboxPrefiltered8;
    private skyboxPrefiltered4;

    private skyboxCubeMap;
    private skyboxModel;
    private skyboxIntensity = 1;
    private skyboxMip = 0;

    private models;
    private lights;
    private globalLights;
    private localLights;
    private updateShaders = true;

    private gravity;


  }
}
