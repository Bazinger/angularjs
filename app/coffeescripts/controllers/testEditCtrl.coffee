vprAppControllers.controller 'TestEditCtrl', [ '$scope', '$routeParams', '$log', 'testSvc', ($scope, $routeParams, $log, testSvc) ->

  type = $routeParams.type

  if $routeParams.testId == 'new'
    $scope.rev_id = $routeParams.revId
    $scope.editTest = {
      rev_id : rev_id
    }
  else
    testSvc.asyncTest $routeParams.testId
      .then (test) ->
        $scope.rev_id = test.rev_id
        $scope.editTest = test

  $scope.cancelEdit = () ->
    $scope.goto "/tests/#{type}/#{$scope.rev_id}"

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.submitTest= (editForm) ->
    testSvc.asyncSaveTest angular.copy editForm
      .then () -> $scope.goto "/tests/#{type}/#{$scope.rev_id}"

]