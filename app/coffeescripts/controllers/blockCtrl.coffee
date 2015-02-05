vprAppControllers.controller 'BlockCtrl', [
  '$scope', 'blockSvc', ($scope, blockSvc) ->

    init = () ->
      blockSvc.asyncBlockList().then (blocks) ->
        $scope.blocks = blocks

    $scope.removeMode = false;
    $scope.tglRemoveMode = () -> $scope.removeMode = !$scope.removeMode

    $scope.removeBlock = (blockId) ->
      blockSvc.asyncRmBlock blockId
        .then do init


    do init
]
