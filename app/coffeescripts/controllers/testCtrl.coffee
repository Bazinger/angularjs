
vprAppControllers.controller 'TestCtrl', [ '$scope', '$routeParams', 'blockSvc', 'testSvc', ($scope, $routeParams, blockSvc, testSvc) ->

  $scope.type      = $routeParams.type
  revId     = $routeParams.revisionId

  initQ = switch $scope.type
    when "block" then blockSvc.asyncBlockRevisionWithParent
    # when "device" then initQ = deviceSvc.aysyncDeviceRevisionWithParent
    else null

  blockSvc.asyncBlockRevisionWithParent revId
    .then (result) ->
      $scope.currentParent = result[0]
      $scope.currentRev = result[1]

      testSvc.asyncTestsForRev revId
        .then (tests) ->
          tests.forEach (test) -> test.showDetails = false
          $scope.tests = tests

  openTests = []

  $scope.tglDetails = (testId) ->
    if (i = openTests.indexOf testId) == -1
      openTests.push(testId)
    else openTests.splice i, 1

  $scope.showDetails = (testId) ->
    (openTests.indexOf testId) != -1

  $scope.confirmRemove = (testId) ->
    testToRemove = _.find $scope.tests, (test) -> test.id == testId

    if testToRemove? then $scope.alert = {
      type: "warning",
      msg: "Are you sure you want to remove #{testToRemove.title}"
      data: testId
    }

  $scope.cancelAlert = () -> delete $scope.alert
  $scope.remove = (testId) ->
    testSvc.asyncRmTest testId
      .then () ->
        $scope.tests = _.reject $scope.tests, (test) -> test.id == testId
        do $scope.cancelAlert

]
