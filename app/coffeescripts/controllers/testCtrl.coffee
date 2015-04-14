
vprAppControllers.controller 'TestCtrl', [ '$scope', '$routeParams', '$log','blockSvc', 'testSvc', 'deviceSvc','utilSvc',($scope, $routeParams, $log, blockSvc, testSvc, deviceSvc,utilSvc) ->

  $scope.type      = $routeParams.type
  revId     = $routeParams.revisionId

  switch $scope.type
    when "block" then initPromise = blockSvc.asyncBlockRevisionWithParent revId
    when "device" then initPromise = deviceSvc.asyncDeviceRevisionWithParent revId
    else null

  initPromise.then (result) ->
    $scope.currentParent = result[0]
    $scope.currentRev = result[1]

    testSvc.asyncTestsForRev revId
      .then (tests) ->
        currentTests = _.map(_.groupBy( tests, "id" ), (testGroup) ->
          testSvc.getCurrentTest testGroup
        )


        currentTests.forEach (test) -> test.showDetails = false
        $scope.tests = currentTests

  # TODO: add async call to get branches -- maybe move code to TestSvc
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

  $scope.cancelAlert = () ->
    delete $scope.alert
  $scope.remove = (testId) ->
    testSvc.asyncRmTest testId
    .then () ->
      $scope.tests = _.reject $scope.tests, (test) -> test.id == testId
      do $scope.cancelAlert

]
