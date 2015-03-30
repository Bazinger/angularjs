
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

  $scope.diffRevision = (rev1, rev2) ->
    clearDiff(rev1)
    diffFields rev1,rev2
    diffTags rev1,rev2
    diffParams(rev1,rev2)

  clearDiff = (rev) ->
    $("#rev-"+rev.revision).children().removeClass("updated created")
    $("#rev-"+rev.revision+" .params").children().removeClass("updated created")
    $("#rev-"+rev.revision+" .params").children().remove(".deleted")

  diffFields = (a,b) ->
    spec = {"title":"title","instructions":"summary","test_config":"test-config","test_script":"test-script"}
    _.forIn (_.pick a,_.keys(spec)), (v,k) ->
      if a[k] isnt b[k]
        $("#rev-"+a.revision+" ."+spec[k]).addClass("updated")

  diffTags = (a,b) ->
    if not (a.tags.length is b.tags.length and a.tags.every (el, i) -> el is b.tags[i])
      $("#rev-"+a.revision+" .tags").addClass("updated")

  diffParams = (a,b) ->
    _.forEach a.test_params,(a_param) ->
      result = _.find b.test_params, (b_param) ->
        b_param.name is a_param.name
      if !result
        $("#rev-"+a.revision+" .param:contains('"+a_param.name+"')").addClass("created")
        console.log 'param ' + a_param.name + ' has been added.'
      else if a_param.value is result.value
        console.log a_param.name + ' has not been updated.'
      else if a_param.value isnt result.value
        $("#rev-"+a.revision+" .param:contains('"+a_param.name+"')").addClass("updated")
        console.log a_param.name + ' has been updated.'
    _.forEach b.test_params,(b_param) ->
      result = _.find a.test_params, (a_param) ->
        b_param.name is a_param.name
      if !result
        $('<div class="param deleted"><div class="small">'+b_param.name+'</div><strong>'+b_param.value+'</strong></div>').appendTo("#rev-"+a.revision+" .params")
        console.log 'param ' + b_param.name + ' has been deleted.'

  do _init

]
