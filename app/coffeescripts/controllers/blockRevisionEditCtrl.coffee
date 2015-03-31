vprAppControllers.controller 'BlockRevisionEditCtrl', [ '$scope', '$routeParams', '$log', 'blockSvc', ($scope, $routeParams, $log, blockSvc) ->

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
    $scope.editBlockRevision = {
      block_id: $routeParams.blockId,
      description: "",
      created_on: do Date.now
    }

    # we base our revision on the previous
    # highest revision. To get that we will
    # load the parent block and all it's
    # revisions

    blockSvc.asyncRevisionsForBlock($routeParams.blockId).then (revisions) ->
      if revisions?
        $scope.mmr = _.max _.pluck(revisions, 'major_revision')
        this_mjr = (r) -> r.major_revision == $scope.mmr
        $scope.mir =  _.max _.pluck(_.filter(revisions, this_mjr), 'minor_revision')

        $scope.revisionType = "i"
        $scope.revision = $scope.nextRevision 'i'

        $scope.newRevision = true

  else
    $scope.newRevision = false
    blockSvc.asyncBlockRevision $routeParams.revisionId
    .then (revision) ->
      $scope.editBlockRevision = revision
      $scope.revision = "#{revision.major_revision}.#{revision.minor_revision}"

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.submitBlockRevision = (editForm) ->
    revisionParts = $scope.revision.split '.'
    editForm.major_revision = revisionParts[0]
    editForm.minor_revision = revisionParts[1]

    blockSvc.asyncSaveBlockRevision angular.copy editForm
    .then () -> $scope.goto "/blocks/#{$scope.editBlockRevision.block_id}"

  $scope.cancelEdit = () ->
    $scope.goto "/blocks/#{$scope.editBlockRevision.block_id}"

]