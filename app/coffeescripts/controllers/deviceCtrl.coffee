vprAppControllers.controller 'DeviceCtrl', [ '$scope', '$routeParams', 'deviceSvc', ($scope, $routeParams, deviceSvc) ->

# if we are called with an active device,
# lets set that up ...

# Device Support
  init = () ->
    deviceSvc.asyncDeviceList().then (devices) ->
      $scope.devices = devices

  $scope.removeMode = false;
  $scope.tglRemoveMode = () -> $scope.removeMode = !$scope.removeMode

  $scope.removeDevice = (deviceId) ->
    deviceSvc.asyncRmDevice deviceId
    .then do init

  $scope.removeRevision = (revisionId) ->
    deviceSvc.asyncRmDeviceRevision revisionId
    .then () ->
      do init

      if $scope.activeDevice? then $scope.loadDevice($scope.activeDevice)

  # Device Revision Support
  $scope.rev_removeMode = false;
  $scope.tglRevRemoveMode = () -> $scope.rev_removeMode = !$scope.rev_removeMode

  $scope.loadDevice = (device_id) ->

    $scope.activeDevice = device_id

    deviceSvc.asyncRevisionsForDevice(device_id)
    .then (revisions) ->
      $scope.device_revisions = do revisions.reverse

  $scope.removeActive = () ->
    delete $scope.activeDevice


  do init

  if $routeParams.activeDevice then $scope.loadDevice($routeParams.activeDevice)
]
