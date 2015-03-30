
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

  $scope.getRevisions = (test) ->
    revisions = []
    _.forEach $scope.tests, (t) ->
      revisions.push t unless t.revision is test.revision
    return revisions

  $scope.diffMode = false
  $scope.diffRevision = (rev1, rev2) ->
    $scope.diffMode = true
    $scope.tests = [rev1,rev2]
    $scope.tglDetails rev2.id, rev2.revision, rev2.branch
    clearDiff(rev1,rev2)
    diffFields rev1,rev2
    diffTags rev1,rev2
    diffParams rev1,rev2

  $scope.reset = () ->
    $scope.diffMode = false
    do _init

  clearDiff = (rev1,rev2) ->
    $("#rev-"+rev1.revision).children().removeClass("updated created")
    $("#rev-"+rev1.revision+" .params").children().removeClass("updated created")
    $("#rev-"+rev2.revision).children().removeClass("deleted")
    $("#rev-"+rev2.revision+" .params").children().removeClass("deleted")


  diffFields = (a,b) ->
    console.log "a",a,"b",b
    spec = {"title":"title","instructions":"summary","test_config":"test-config","test_script":"test-script"}
    _.forIn (_.pick a,_.keys(spec)), (v,k) ->
      if a[k] isnt b[k]
        $("#rev-"+a.revision+" ."+spec[k]).addClass("updated")

    if typeof a["test_script"] isnt 'undefined' and typeof b["test_script"] is 'undefined'
      $("#rev-"+a.revision+" .test-script").addClass("created")

    if typeof a["test_script"] is 'undefined' and typeof b["test_script"] isnt 'undefined'
      $("#rev-"+b.revision+" .test-script").addClass("deleted")

    if typeof a["meas_plan"] isnt 'undefined' and typeof b["meas_plan"] is 'undefined'
      console.log "meas_plan created"
      $("#rev-"+a.revision+" .meas-plan").addClass("created")

    if typeof a["meas_plan"] is 'undefined' and typeof b["meas_plan"] isnt 'undefined'
      console.log "meas_plan deleted"
      $("#rev-"+b.revision+" .meas-plan").addClass("deleted")

    if typeof a["spotfire_template"] isnt 'undefined' and typeof b["spotfire_template"] is 'undefined'
      $("#rev-"+a.revision+" .spotfire-template").addClass("created")

    if typeof a["spotfire_template"] is 'undefined' and typeof b["spotfire_template"] isnt 'undefined'
      $("#rev-"+b.revision+" .spotfire-template").addClass("deleted")

  diffTags = (a,b) ->
    if not (a.tags.length is b.tags.length and a.tags.every (el, i) -> el is b.tags[i])
      $("#rev-"+a.revision+" .tags").addClass("updated")

  diffParams = (a,b) ->
    _.forEach a.test_params,(a_param) ->
      result = _.find b.test_params, (b_param) ->
        b_param.name is a_param.name
      if !result
        $("#rev-"+a.revision+" .param:contains('"+a_param.name+"')").addClass("created")
      else if a_param.value isnt result.value
        $("#rev-"+a.revision+" .param:contains('"+a_param.name+"')").addClass("updated")

    _.forEach b.test_params,(b_param) ->
      result = _.find a.test_params, (a_param) ->
        b_param.name is a_param.name
      if !result
        selector = "#rev-"+b.revision+" .param:contains('"+b_param.name+"')"
        setTimeout (() -> $(selector).addClass("deleted")), 50

  do _init

]
