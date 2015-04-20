vprAppControllers.controller 'BlockCtrl', [ '$scope', '$routeParams', 'blockSvc', ($scope, $routeParams, blockSvc) ->

    # if we are called with an active block,
    # lets set that up ...


    # Block Support
    init = () ->
      blockSvc.asyncBlockList().then (blocks) ->
        $scope.blocks = blocks

    $scope.removeMode = false;
    $scope.tglRemoveMode = () -> $scope.removeMode = !$scope.removeMode

    $scope.removeBlock = (id) ->
      blockSvc.asyncRmBlock id
      .then () ->
        console.log  $scope.blocks
        $scope.blocks = _.reject $scope.blocks, (block) -> block.id == id
        console.log  $scope.blocks
        $scope.cancelBlockAlert()

    $scope.confirmRemoveBlock = (id) ->
      blockToRemove = _.find $scope.blocks, (block) -> block.id == id

      if blockToRemove? then $scope.blockAlert = {
        type: "warning",
        msg: "Are you sure you want to remove #{blockToRemove.name}?"
        data: id
      }


    $scope.cancelBlockAlert = () ->
      delete $scope.blockAlert

    # Block Revision Support
    $scope.rev_removeMode = false;
    $scope.tglRevRemoveMode = () -> $scope.rev_removeMode = !$scope.rev_removeMode

    $scope.loadBlock = (block_id) ->

      $scope.activeBlock = block_id

      blockSvc.asyncRevisionsForBlock(block_id)
        .then (revisions) ->
          $scope.block_revisions = do revisions.reverse

    $scope.removeActive = () ->
      delete $scope.activeBlock

    $scope.removeRevision = (id) ->
      blockSvc.asyncRmBlockRevision id
      .then () ->
        $scope.block_revisions = _.reject $scope.block_revisions, (revision) -> revision.id == id
        $scope.cancelRevisionAlert()

    $scope.confirmRemoveRevision = (id) ->
      revisionToRemove = _.find $scope.block_revisions, (revision) -> revision.id == id

      if revisionToRemove? then $scope.revisionAlert = {
        type: "warning",
        msg: "Are you sure you want to remove #{revisionToRemove.major_revision}.#{revisionToRemove.minor_revision}?"
        data: id
      }

    $scope.cancelRevisionAlert = () ->
      delete $scope.revisionAlert
    do init

    if $routeParams.activeBlock then $scope.loadBlock($routeParams.activeBlock)
]
