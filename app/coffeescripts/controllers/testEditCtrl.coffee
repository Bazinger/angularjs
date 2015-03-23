vprAppControllers.controller 'TestEditCtrl', [ '$scope', '$routeParams', '$log', 'testSvc', ($scope, $routeParams, $log, testSvc) ->

  type = $routeParams.type

  if $routeParams.testId == 'new'
    $scope.rev_id = $routeParams.revId
    $scope.editTest = {
      rev_id : $routeParams.revId
    }
  else
    testSvc.asyncTest $routeParams.testId
      .then (test) ->
        $scope.rev_id = test.rev_id
        $scope.editTest = angular.copy test

    testSvc.asyncBranchesForTest $routeParams.testId
      .then (branches) -> $scope.branches = branches

  $scope.cancelEdit = () ->
    $scope.goto "/tests/#{type}/#{$scope.rev_id}"

  $scope.trySubmit = false
  $scope.validate = () ->
    $scope.trySubmit = true

  $scope.branchObj = {}

  $scope.newBranchAdd = false
  $scope.toggleBranchAdd = () -> $scope.newBranchAdd = !$scope.newBranchAdd

  $scope.selectBranch = (branch) -> $scope.editTest.branch = branch

  $scope.submitTest= (editForm) ->

    testSvc.asyncSaveAndRevisionTest angular.copy( editForm ), $scope.branchObj.newBranch
      .then () -> $scope.goto "/tests/#{type}/#{$scope.rev_id}"

]