vprAppControllers.controller 'BlockCtrl', [ '$scope', '$routeParams', 'blockSvc', ($scope, $routeParams, blockSvc) ->

    # if we are called with an active block,
    # lets set that up ...


    # Block Support
    init = () ->
      blockSvc.asyncBlockList().then (blocks) ->
        $scope.blocks = blocks

    $scope.removeMode = false;
    $scope.tglRemoveMode = () -> $scope.removeMode = !$scope.removeMode

    $scope.removeBlock = (blockId) ->
      blockSvc.asyncRmBlock blockId
        .then do init

    $scope.removeRevision = (revisionId) ->
      blockSvc.asyncRmBlockRevision revisionId
      .then () ->
        do init

        if $scope.activeBlock? then $scope.loadBlock($scope.activeBlock)

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


    do init

    if $routeParams.activeBlock then $scope.loadBlock($routeParams.activeBlock)
]
