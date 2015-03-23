
vprAppControllers.controller 'TestHistoryCtrl', [ '$scope', '$routeParams', '$q', 'blockSvc', 'testSvc', ($scope, $routeParams, $q, blockSvc, testSvc) ->

  testId        = $routeParams.testId
  $scope.type   = $routeParams.type

  _init = (forBranch) ->
    testSvc.asyncTestHistory testId
      .then (history) ->
        branchGroups = _.groupBy history, "branch"
        $scope.branches = _.map(branchGroups, (group) ->
          group[0].branch
        )

        $scope.currentTest = testSvc.getCurrentTest history

        if !forBranch?
          $scope.currentBranch = $scope.currentTest.branch
        else
          $scope.currentBranch = forBranch

        $scope.tests = _.sortBy(_.find branchGroups, (group) ->
          group[0].branch == $scope.currentBranch
        , (test) -> test.revision).reverse()

  # show history for selected branch
  $scope.selectBranch = () -> $scope.tests = _init $scope.currentBranch

  openTests = []

  $scope.isCurrent = (id, r, b) ->
    testSvc.compareTests {id: id, revision: r, branch: b}, $scope.currentTest

  $scope.makeCurrent = (test) ->
    newTest = _.find $scope.tests, (t) ->
      testSvc.compareTests {id: test.id, revision: test.revision, branch: test.branch}, t

    newTest.is_current = true

    oldTest = angular.copy $scope.currentTest
    delete oldTest.is_current

    deferred = do $q.defer

    $q.all [ testSvc.asyncSaveTest(newTest), testSvc.asyncSaveTest(oldTest) ]
      .then (result) ->
        $scope.goto "/tests/#{$scope.type}/#{newTest.rev_id}"

    deferred.promise

  $scope.tglDetails = (testId, revision, branch) ->
    if (i = openTests.indexOf JSON.stringify({ id: testId, revision: revision, branch }) ) == -1
      openTests.push JSON.stringify({ id: testId, revision: revision, branch })
    else openTests.splice i, 1

  $scope.showDetails = (testId, revision, branch) ->
    (openTests.indexOf JSON.stringify({ id: testId, revision: revision, branch })) != -1

  $scope.cancelAlert = () -> delete $scope.alert

  do _init

]
