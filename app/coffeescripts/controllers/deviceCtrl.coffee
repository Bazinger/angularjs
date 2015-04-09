vprAppControllers.controller 'DeviceCtrl', [ '$scope', '$routeParams', 'deviceSvc','testSvc' ,($scope, $routeParams, deviceSvc,testSvc) ->

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

  $scope.removeRevision = (deviceRevisionId) ->
    deviceSvc.asyncRmDeviceRevision deviceRevisionId
    .then () ->
      do init

      if $scope.activeDevice? then $scope.loadDevice($scope.activeDevice)


  # Device Revision Support
  $scope.rev_removeMode = false
  $scope.tglRevRemoveMode = () -> $scope.rev_removeMode = !$scope.rev_removeMode

  $scope.loadDevice = (device_id) ->

    $scope.activeDevice = device_id

    deviceSvc.asyncRevisionsForDevice(device_id)
    .then (revisions) ->
      $scope.device_revisions = do revisions.reverse

  $scope.removeActive = () ->
    delete $scope.activeDevice

  # Device Revision Block Support
  $scope.block_removeMode = false
  $scope.tglBlockRemoveMode = () -> $scope.block_removeMode = !$scope.block_removeMode

  $scope.loadDeviceRevision = (deviceRevision) ->
    $scope.activeDeviceRevision = deviceRevision.id
    $scope.device_revisions=[]
    $scope.device_revisions.push deviceRevision
    testSvc.asyncTestsForRev deviceRevision.id
    .then (tests) ->
      $scope.testCount = tests.length

    deviceSvc.asyncBlocksForDeviceRevision(deviceRevision.id)
    .then (blocks) ->
      $scope.device_revision_blocks = do blocks.reverse

  $scope.removeActiveDeviceRevision = () ->
    delete $scope.activeDeviceRevision
    $scope.loadDevice $scope.activeDevice



  do init

  if $routeParams.activeDevice then $scope.loadDevice($routeParams.activeDevice)
]
