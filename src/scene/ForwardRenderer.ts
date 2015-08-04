module orange {
  export class ForwardRenderer {

    private projId: ScopeId;
    private viewId: ScopeId;
    private viewId3: ScopeId;
    private viewInvId: ScopeId;
    private viewProjId: ScopeId;
    private nearClipId: ScopeId;
    private farClipId: ScopeId;
    private viewPosId: ScopeId;
    private lightRadiusId: ScopeId;
    private fogColorId: ScopeId;
    private fogStartId: ScopeId;
    private fogEndId: ScopeId;
    private fogDensityId: ScopeId;
    private modelMatrixId: ScopeId;
    private normalMatrixId: ScopeId;
    private poseMatrixId: ScopeId;
    private boneTextureId: ScopeId;
    private boneTextureSizeId: ScopeId;
    private alphaTestId: ScopeId;

    constructor(private graphicsDevcie: GraphicsDevice) {
      var scope = graphicsDevcie.scope;
      this.projId = scope.resolve('matrix_projection');
      this.viewId = scope.resolve('matrix_view');
      this.viewId3 = scope.resolve('matrix_view3');
      this.viewInvId = scope.resolve('matrix_viewInverse');
      this.viewProjId = scope.resolve('matrix_viewProjection');
      this.viewPosId = scope.resolve('view_position');
      this.nearClipId = scope.resolve('camera_near');
      this.farClipId = scope.resolve('camera_far');
      this.lightRadiusId = scope.resolve('light_radius');

      this.fogColorId = scope.resolve('fog_color');
      this.fogStartId = scope.resolve('fog_start');
      this.fogEndId = scope.resolve('fog_end');
      this.fogDensityId = scope.resolve('fog_density');

      this.modelMatrixId = scope.resolve('matrix_model');
      this.normalMatrixId = scope.resolve('matrix_normal');
      this.poseMatrixId = scope.resolve('matrix_pose[0]');
      this.boneTextureId = scope.resolve('texture_poseMap');
      this.boneTextureSizeId = scope.resolve('texture_poseMapSize');

      this.alphaTestId = scope.resolve('alpha_ref');
    }

    render(scene: Scene, camera: Camera) {
      var device = this.graphicsDevcie;
      var scope = device.scope;

      scene.depthDrawCalls = 0;
      scene.shadowDrawCalls = 0;
      scene.forwardDrawCalls = 0;

      // TODO
      // update shader
      // 


    }
  }
}
