vprAppControllers.controller 'DeviceRevisionEditCtrl', [ '$scope', '$routeParams', '$log', '$q','deviceSvc','blockSvc', 'testSvc','utilSvc',($scope, $routeParams, $log,$q, deviceSvc,blockSvc,testSvc,utilSvc) ->

  $scope.foo = []
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
      $scope.loadDeviceParams()


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


  $scope.loadBlockRevisionsList = () ->
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
    #console.log 'adding a block revision'
    item =  _.find $scope.editDeviceRevision.block_revisions, (val) -> val.id is $scope.selectedBlockRevision.id
    if not item?
      #console.log 'adding new block revision'
       # adding a blockRevisionItem with default device parameter values
      blockSvc.asyncCreateBlockRevisionItem $scope.selectedBlockRevision.id
        .then (item) ->
          #console.log 'new block revision item',item
          $scope.editDeviceRevision.block_revisions.push item
          $scope.loadDeviceParams()


  $scope.device_params_list = []
  $scope.loadDeviceParams = () ->
    block_revisions = $scope.editDeviceRevision.block_revisions
    results = []
    default_params = [] 
    promises = []

    for rev in block_revisions
      do (rev) ->
        deferred = $q.defer()
        promises.push deferred.promise
        #console.log 'processing rev',rev        
        testSvc.asyncTestsForRev rev.id
        .then (tests) ->

          # get default device parameters for all current tests that belong to this rev
          default_params = utilSvc.parseDeviceParams tests

          # overwrite default values with device values
          for param in $scope.editDeviceRevision.device_params
            if param.default            
              item = _.find default_params, (v) -> v.placeholder is param.placeholder
              if item?                
                item.value = param.value

          deferred.resolve default_params

    $q.all promises
    .then (results) ->
      $scope.device_params_list = utilSvc.mergeDeviceParameters results
      console.log '$scope.device_params_list',$scope.device_params_list

  $scope.blockRevisionRemove = (item) ->
    $scope.editDeviceRevision.block_revisions = _.reject $scope.editDeviceRevision.block_revisions,(i) -> i.id is item.id
    $scope.loadDeviceParams()
    
  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.processDeviceParams = () ->
    for param in $scope.device_params_list
      #console.log 'processing param',param
      if param.value.trim() is ''
        # remove parameter from device revision
        $scope.editDeviceRevision.device_params = _.reject $scope.editDeviceRevision.device_params, (v) -> 
          #console.log v,param
          v.placeholder is param.placeholder
      else
        # add or update device revision parameters
        item = _.find $scope.editDeviceRevision.device_params, (v) -> v.placeholder is param.placeholder
        if item? then item.value = param.value 
        else $scope.editDeviceRevision.device_params.push param


  $scope.submitDeviceRevision = (editForm) ->
    revisionParts = $scope.revision.split '.'
    editForm.major_revision = revisionParts[0]
    editForm.minor_revision = revisionParts[1]
    #console.log 'device_params', $scope.device_params_list
    $scope.processDeviceParams()
    console.log 'editForm',editForm
    #deviceSvc.asyncSaveDeviceRevision angular.copy editForm
    #.then () -> $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"

  $scope.cancelEdit = () ->
    $scope.goto "/devices/#{$scope.editDeviceRevision.device_id}"


]