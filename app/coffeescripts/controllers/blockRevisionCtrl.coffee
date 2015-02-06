vprAppControllers.controller 'BlockRevisionEditCtrl', [ '$scope', '$routeParams', '$log', 'blockSvc', ($scope, $routeParams, $log, blockSvc) ->

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

    blockSvc.asyncRevisionsForBlock($routeParams.block_id).then (revisions) ->
      if revisions? then
      $scope.max_mjr_revision =
        _.reduce _.pluck(revisions, 'major_revision'), (max, a) ->
          if max?
            if a > max then a else max
          else a
      $scope.max_min_revision = _.max _.pluck(revisions, 'minor_revision')

    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $scope.revision = () ->
      switch $scope.revisionType
        when 'M'
          mmr = $scope.max_mjr_revision
          nmr = if mmr?
            if mmr[0] == 'Z'
              ('A' for i in [1..mmr.length+1]).join ''
            else
              letters[letters.indexOf(mmr[0])+1] for i in [1..mmr.length]
          else 'A'
          # return
          "#{nmr}0"
        when 'i'
          mir = $scope.max_min_revision
          nir = mir + 1
          # return
          "#{$scope.max_mjr_revision}#{nir}"

    $scope.newRevision = true;
  else
    $scope.newRevision = false
    blockSvc.asyncBlockRevision $routeParams.revisionId
    .then (revision) ->
      $scope.editBlockRevision = revision
      $scope.revision = "#{revision.major_revision}#{revision.minor_revision}"

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.submitBlockRevision = (editForm) ->
    blockSvc.asyncSaveBlockRevision angular.copy editForm
    .then () -> $scope.goto '/blocks'

  $scope.cancelEdit = () ->
    $scope.goto("/blocks/#{$scope.editBlockRevision.block_id}")

]