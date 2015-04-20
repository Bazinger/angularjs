vprAppControllers.controller 'BlockEditCtrl', [ '$scope', '$routeParams', '$log', 'blockSvc', ($scope, $routeParams, $log, blockSvc) ->


  if $routeParams.blockId == 'new'
    $scope.editBlock = {
      name: "",
      owner: "",
      description: "",
      tags: []
    }
  else
    blockSvc.asyncBlock $routeParams.blockId
      .then (block) -> $scope.editBlock = block
      #, (err) -> $scope.error = err

  $scope.users = [ { username: "dnye", fullName: "Donovan Nye"}, { username: "tg", fullName: "That Guy"} ]

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.cancelEditBlock = () ->
    if $routeParams.deviceId and $routeParams.revisionId
      $scope.goto('/devices')
    else
      $scope.goto('/blocks')

  $scope.submitBlock = (editForm) ->
    blockSvc.asyncSaveBlock angular.copy editForm
      .then () ->
        if $routeParams.deviceId and $routeParams.revisionId
          $scope.goto('/devices')
        else
          $scope.goto('/blocks')



]

