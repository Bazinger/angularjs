vprAppControllers.controller 'DeviceRevisionEditCtrl', [ '$scope', '$routeParams', '$log', 'deviceSvc','blockSvc', ($scope, $routeParams, $log, deviceSvc,blockSvc) ->

  $scope.block_revisions_list = []

  if $routeParams.revisionId == 'new'
    $scope.editDeviceRevision = {
      device_id: $routeParams.deviceId,
      description: "",
      created_on: do Date.now,
      block_revisions: []
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
      do $scope.loadBlockRevisionsList


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

  # get blocks
  blockSvc.asyncBlockList()
  .then (blocks) ->
    $scope.blocks = blocks

  $scope.getBlockRevisions = () ->
    blockSvc.asyncRevisionsForBlock($scope.selectedBlock.id)
    .then (block_revisions) ->
      $scope.block_revisions = block_revisions

  $scope.fullRevision = (block_revision) ->
    block_revision.major_revision + '.' + block_revision.minor_revision

  $scope.blockRevisionAdd = () ->
    item = $scope.createBlockRevisionItem $scope.selectedBlock.id,$scope.selectedBlock.name,$scope.selectedBlockRevision.major_revision,$scope.selectedBlockRevision.minor_revision
    $scope.block_revisions_list.push item

  $scope.blockRevisionRemove = (item) ->
    $scope.block_revisions_list = _.reject $scope.block_revisions_list,(i) -> i.id is item.id

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.submitDeviceRevision = (editForm) ->
    revisionParts = $scope.revision.split '.'
    editForm.major_revision = revisionParts[0]
    editForm.minor_revision = revisionParts[1]
    editForm.block_revisions = _.pluck($scope.block_revisions_list,'id')

    deviceSvc.asyncSaveDeviceRevision angular.copy editForm
    .then () -> $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"

  $scope.cancelEdit = () ->
    $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"

  $scope.createBlockRevisionItem =  (id,name,major_revision,minor_revision) ->
    {
      id: id,
      name: name + ' ' + major_revision + '.' + minor_revision
    }

  $scope.loadBlockRevisionsList =  () ->

    if typeof $scope.editDeviceRevision.block_revisions is 'undefined'
      $scope.editDeviceRevision.block_revisions = []
    else
      for id in $scope.editDeviceRevision.block_revisions
        blockSvc.asyncBlockRevisionWithParent(id)
        .then (results) ->
          console.log 'results',results
          block_revision = {
            id: results[0].id,
            name: results[0].name + ' ' + results[1].major_revision + '.' + results[1].minor_revision
          }
          $scope.block_revisions_list.push block_revision

]