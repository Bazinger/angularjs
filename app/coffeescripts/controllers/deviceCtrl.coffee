vprAppControllers.controller 'DeviceCtrl', [ '$scope', '$routeParams', 'deviceSvc','testSvc', 'blockSvc' ,($scope, $routeParams, deviceSvc,testSvc,blockSvc) ->

# if we are called with an active device,
# lets set that up ...

# Device Support
  init = () ->
    deviceSvc.asyncDeviceList().then (devices) ->
      $scope.devices = devices



  $scope.removeMode = false;
  $scope.tglRemoveMode = () -> $scope.removeMode = !$scope.removeMode


  $scope.removeDevice = (id) ->
    deviceSvc.asyncRmDevice id
    .then () ->
      $scope.devices = _.reject $scope.devices, (device) -> device.id == id
      $scope.cancelDeviceAlert()

  $scope.confirmRemoveDevice = (id) ->
    deviceToRemove = _.find $scope.devices, (device) -> device.id == id
    console.log deviceToRemove
    if deviceToRemove? then $scope.deviceAlert = {
      type: "warning",
      msg: "Are you sure you want to remove #{deviceToRemove.name}?"
      data: id
    }

  $scope.cancelDeviceAlert = () ->
    delete $scope.deviceAlert

  # Device Revision Support
  $scope.rev_removeMode = false
  $scope.tglRevRemoveMode = () -> $scope.rev_removeMode = !$scope.rev_removeMode

  $scope.loadDevice = (device) ->
    $scope.activeDevice = device.id
    deviceSvc.asyncRevisionsForDevice(device.id)
    .then (revisions) ->
      for revision in revisions
        revision.name = device.name
      $scope.device_revisions = do revisions.reverse


  $scope.removeActive = () ->
    delete $scope.activeDevice

  # Device Revision Block Support
  $scope.block_removeMode = false
  $scope.tglBlockRemoveMode = () -> $scope.block_removeMode = !$scope.block_removeMode

  $scope.loadActiveDeviceRevision = (revision) ->
    $scope.activeDeviceRevision = revision.id
    testSvc.asyncTestsForRev revision.id
    .then (tests) ->
      $scope.activeDeviceRevisionTestCount = 0
      for test in tests
        if test.is_current then $scope.activeDeviceRevisionTestCount++

  $scope.loadTestCount = (revision) ->
    testSvc.asyncTestsForRev revision.id
    .then (tests) ->
      $scope.testCount = tests.length

  $scope.refreshDeviceRevision = (revision) ->
    $scope.device_revisions=[]
    $scope.device_revisions.push revision

  $scope.loadBlockRevisions = (revision) ->
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
        $scope.block_revisions.push item


  $scope.removeActiveDeviceRevision = () ->
    delete $scope.activeDeviceRevision
    $scope.loadDevice $scope.activeDevice

  $scope.removeRevision = (id) ->
    deviceSvc.asyncRmDeviceRevision id
    .then () ->
      $scope.device_revisions = _.reject $scope.device_revisions, (revision) -> revision.id == id
      $scope.cancelRevisionAlert()

  $scope.confirmRemoveRevision = (id) ->
    revisionToRemove = _.find $scope.device_revisions, (revision) -> revision.id == id

    if revisionToRemove? then $scope.revisionAlert = {
      type: "warning",
      msg: "Are you sure you want to remove #{revisionToRemove.major_revision}.#{revisionToRemove.minor_revision}?"
      data: id
    }

  $scope.cancelRevisionAlert = () ->
    delete $scope.revisionAlert



  do init

  if $routeParams.activeDevice
    $scope.loadDevice($routeParams.activeDevice)
    $scope.activeDevice = $routeParams.activeDevice
]
