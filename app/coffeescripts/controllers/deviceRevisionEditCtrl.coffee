vprAppControllers.controller 'DeviceRevisionEditCtrl', [ '$scope', '$routeParams', '$log', 'deviceSvc', ($scope, $routeParams, $log, deviceSvc) ->

  $scope.nextRevision = (revisionType) ->
    mmr = Number($scope.mmr)
    mir = Number($scope.mir)

    switch revisionType
      when 'M'
        "#{mmr+1}.0"
      when 'i'
        "#{mmr}.#{mir+1}"

  $scope.changeRevision = (revisionType) ->
    $scope.revision = $scope.nextRevision revisionType

  if $routeParams.revisionId == 'new'
    $scope.editDeviceRevision = {
      device_id: $routeParams.deviceId,
      description: "",
      created_on: do Date.now
    }
    # we base our revision on the previous
    # highest revision. To get that we will
    # load the parent device and all it's
    # revisions

    deviceSvc.asyncRevisionsForDevice($routeParams.deviceId).then (revisions) ->
      if revisions.length? and revisions.length > 0
        $scope.mmr = _.max _.pluck(revisions, 'major_revision')
        this_mjr = (r) -> r.major_revision == $scope.mmr
        $scope.mir =  _.max _.pluck(_.filter(revisions, this_mjr), 'minor_revision')
      else
        $scope.mmr = 0
        $scope.mir = 0

      $scope.revisionType = "i"
      $scope.revision = $scope.nextRevision 'i'

      $scope.newRevision = true

  else
    $scope.newRevision = false
    deviceSvc.asyncDeviceRevision $routeParams.revisionId
    .then (revision) ->
      $scope.editDeviceRevision = revision
      $scope.revision = "#{revision.major_revision}.#{revision.minor_revision}"

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.submitDeviceRevision = (editForm) ->
    console.log 'submitDeviceRevision'
    revisionParts = $scope.revision.split '.'
    editForm.major_revision = revisionParts[0]
    editForm.minor_revision = revisionParts[1]

    deviceSvc.asyncSaveDeviceRevision angular.copy editForm
    .then () -> $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"

  $scope.cancelEdit = () ->
    $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"

]