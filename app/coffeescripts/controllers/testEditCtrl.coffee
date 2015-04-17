vprAppControllers.controller 'TestEditCtrl', [ '$scope', '$routeParams', '$log', 'testSvc', 'dataSvc', ($scope, $routeParams, $log, testSvc, dataSvc) ->

  type = $routeParams.type


  if $routeParams.testId == 'new'
    $scope.newTest = true
    $scope.rev_id = $routeParams.revId
    dataSvc.asyncNewId().then (id) ->
      $scope.editTest = {
        id : id
        rev_id : $routeParams.revId
        branch : "default",
        tags : [],
        test_params: []
      }
  else
    $scope.newTest = false
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
      $(".testEdit .plist .plist-body:nth-child("+(v.index+3)+") .name").addClass("ng-invalid")
    _.forEach singles, (v) ->
      $(".testEdit .plist .plist-body:nth-child("+(v.index+3)+") .name").removeClass("ng-invalid")
    $scope.multiples = multiples


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
      testSvc.asyncSaveAndRevisionTest angular.copy( editForm ), $scope.branchObj.newBranch
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

