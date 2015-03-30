vprAppControllers.controller 'TestEditCtrl', [ '$scope', '$routeParams', '$log', 'testSvc', ($scope, $routeParams, $log, testSvc) ->

  type = $routeParams.type


  if $routeParams.testId == 'new'
    $scope.rev_id = $routeParams.revId
    $scope.editTest = {
      rev_id : $routeParams.revId,
      test_params: []
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

  $scope.paramAdd = () ->
    $scope.editTest.test_params.unshift({name: '',value: ''})

  $scope.paramRemove = ( params, param) ->
    _.find params, (p,i) ->
      if p.name==param.name
        params.splice i, 1
        $scope.testForm.$dirty = true


  $scope.editBranch = (branchToEdit) ->
    $scope.newBranchAdd = true
    $scope.branchObj.newBranch = branchToEdit
    $scope.branchObj.branchToChange = angular.copy branchToEdit

  $scope.cancelEditBranch = () ->
    delete $scope.branchObj.newBranch
    delete $scope.branchObj.branchToChange

    do $scope.toggleBranchAdd

  $scope.submitTest= (editForm) ->
    editForm.modified_on = new Date().getTime()
    saveTest = () ->

      testSvc.asyncSaveAndRevisionTest angular.copy( editForm ), $scope.branchObj.newBranch, $scope.branchObj.branchToChange
      .then () -> $scope.goto "/tests/#{type}/#{$scope.rev_id}"

    if $scope.branchObj.branchToChange? # then we have changed our branch name! so update everywhere before proceeding
      testSvc.asyncChangeBranch(
        editForm.id, $scope.branchObj.branchToChange, $scope.branchObj.newBranch
      ).then () ->
        editForm.branch = $scope.branchObj.newBranch
        do saveTest
    else
      do saveTest

]