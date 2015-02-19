vprAppControllers.controller 'BlockRevisionEditCtrl', [ '$scope', '$routeParams', '$log', 'blockSvc', ($scope, $routeParams, $log, blockSvc) ->

  $scope.nextRevision = () ->
    switch $scope.revisionType
      when 'M'
        "#{$scope.mmr+1}.0"
      when 'i'
        "#{$scope.mmr}.#{$scope.mir+1}"

  $scope.$watch 'revisionType', (newValue, oldValue) ->
    $scope.revision = do $scope.nextRevision

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
        $scope.mir = _.max _.pluck(_.filter(revisions, this_mjr), 'minor_revision')

        $scope.revisionType = "i"
        $scope.revision = do $scope.nextRevision

        $scope.newRevision = true;

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
    blockSvc.asyncSaveBlockRevision angular.copy editForm
    .then () -> $scope.goto "/blocks/#{$scope.editBlockRevision.block_id}"

  $scope.cancelEdit = () ->
    $scope.goto "/blocks/#{$scope.editBlockRevision.block_id}"

]