vprAppControllers.controller 'DeviceCtrl', [ '$scope', '$routeParams', 'deviceSvc','testSvc', 'blockSvc' ,($scope, $routeParams, deviceSvc,testSvc,blockSvc) ->

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

  $scope.setActiveDeviceRevision = (revision) -> $scope.activeDeviceRevision = revision.id

  $scope.loadTestCount = (revision) ->
    testSvc.asyncTestsForRev revision.id
    .then (tests) ->
      $scope.testCount = tests.length

  $scope.refreshDeviceRevision = (revision) ->
    $scope.device_revisions=[]
    $scope.device_revisions.push revision

  $scope.loadBlockRevisions = (revision) ->
    console.log 'loadBlockRevisions',revision.block_revisions.reverse
    block_revisions = do revision.block_revisions.reverse
    for block_revision in block_revisions
      $scope.block_revisions = []
      blockSvc.asyncBlockRevisionWithParent block_revision
      .then (results) ->
        item = {
          id: results[1].id
          name: results[0].name
          description: results[1].description
          version: results[1].major_revision + '.' + results[1].minor_revision
        }
        testSvc.asyncTestsForRev results[1].id
        .then (tests) ->
          item.test_count = tests.length
          $scope.block_revisions.push item


  $scope.removeActiveDeviceRevision = () ->
    delete $scope.activeDeviceRevision
    $scope.loadDevice $scope.activeDevice



  do init

  if $routeParams.activeDevice then $scope.loadDevice($routeParams.activeDevice)
]
