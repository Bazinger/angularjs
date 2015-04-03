
vprAppControllers.controller 'HomeCtrl', [
  '$scope', 'blockSvc','deviceSvc', ($scope, blockSvc,deviceSvc) ->

    blockSvc.asyncBlockCount().then (count) ->
     $scope.blockCount = count

    deviceSvc.asyncDeviceCount().then (count) ->
      $scope.deviceCount = count


]
