
vprAppControllers.controller 'HomeCtrl', [
  '$scope', 'blockSvc', ($scope, blockSvc) ->

    blockSvc.asyncBlockCount().then (count) ->
     $scope.blockCount = count

    $scope.deviceCount = 3
]
