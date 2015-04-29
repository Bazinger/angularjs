vprAppControllers.controller 'DeviceRevisionEditCtrl', [ '$scope', '$routeParams', '$log', '$q','deviceSvc','blockSvc', ($scope, $routeParams, $log,$q, deviceSvc,blockSvc) ->


  $scope.block_revisions_list = []


  if $routeParams.revisionId == 'new'
    $scope.editDeviceRevision = {
      device_id: $routeParams.deviceId,
      description: "",
      created_on: do Date.now,
      block_revisions: []
      device_params: []
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

      # load block revisions associated with this release
      $scope.block_revisions_list = revision.block_revisions

  # get blocks for block pulldown
  blockSvc.asyncBlockList()
  .then (blocks) ->
    $scope.blocks = blocks

# methods
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


  $scope.getBlockRevisions = () ->
    blockSvc.asyncRevisionsForBlock($scope.selectedBlock.id)
    .then (block_revisions) ->
      $scope.block_revisions_list = block_revisions

  $scope.fullRevision = (block_revision) ->
    block_revision.major_revision + '.' + block_revision.minor_revision


  $scope.paramAdd = () ->
    $scope.editDeviceRevision.device_params.unshift({name: '',value: '',default:false})

  $scope.paramRemove = ( params, param) ->
    _.find params, (p,i) ->
      if p.name==param.name
        params.splice i, 1
        $scope.deviceRevisionForm.$dirty = true

  $scope.multiples = []
  $scope.checkMultiples = (params) ->
   multiples = []
   singles = []
   _.forEach params, (v,k) ->
     if (_.where params, {'name': v.name}).length > 1
       multiples.push({name: v.name,index: k})
     else
       singles.push({name: v.name,index: k})
   _.forEach multiples, (v) ->
     $("form .plist .plist-body:nth-child("+(v.index+3)+") .name").addClass("ng-invalid")
   _.forEach singles, (v) ->
     $("form .plist .plist-body:nth-child("+(v.index+3)+") .name").removeClass("ng-invalid")
   $scope.multiples = multiples

  $scope.blockRevisionAdd = () ->
    item =  _.find $scope.editDeviceRevision.block_revisions, (val) -> val.id is $scope.selectedBlockRevision.id
    if typeof item is 'undefined'
      # adding a blockRevisionItem with default device parameter values
      $scope.createBlockRevisionItem $scope.selectedBlockRevision.id
        .then (item) ->
          $scope.editDeviceRevision.block_revisions.push item


  $scope.blockRevisionRemove = (item) ->
    $scope.editDeviceRevision.block_revisions = _.reject $scope.editDeviceRevision.block_revisions,(i) -> i.id is item.id

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.submitDeviceRevision = (editForm) ->
    revisionParts = $scope.revision.split '.'
    editForm.major_revision = revisionParts[0]
    editForm.minor_revision = revisionParts[1]
    deviceSvc.asyncSaveDeviceRevision angular.copy editForm
    .then () -> $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"

  $scope.cancelEdit = () ->
    $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"

  $scope.createBlockRevisionItem =  (rev_id) ->
    deferred = $q.defer()

    blockSvc.asyncBlockRevisionWithParent rev_id
    .then (results) ->

      item = {
        id: rev_id,
        name: results[0].name+' '+results[1].major_revision+'.'+results[1].minor_revision
        major_revision: results[1].major_revision
        minor_revision: results[1].minor_revision
      }
      blockSvc.asyncDeviceParamsForBlockRevision rev_id
      .then (default_params) ->
        item.device_params = default_params
        deferred.resolve item

    deferred.promise

]