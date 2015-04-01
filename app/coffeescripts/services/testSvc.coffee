vprAppServices.factory 'testSvc', [ '$log', '$q', 'dataSvc', 'utilSvc',  ($log, $q, dataSvc, utilSvc) ->

  class TestSvc

    asyncTestsForRev: (revId) ->
      utilSvc.handleAsync dataSvc.asyncFind "tests", { "rev_id" : revId }

    asyncTestHistory: (testId) ->
      utilSvc.handleAsync dataSvc.asyncFind "tests", { "id" : testId }

    getCurrentTest: (tests) ->
      # look for an is_current OR
      # group by branch and return either
      # the default branch max if it exists
      # or the max in the first branch in the group
      # by array

      findFromBranches = (_tests) ->
        branchGroups = _.groupBy _tests, "branch"
        branchTests = _.find branchGroups, (ba) -> ba[0].branch == "default" || branchGroups[0]

        _.sortBy(
          branchTests, (t) -> t.revision || -1
        ).reverse()[0]

      _.find(tests, (ti) ->  ti.is_current) || findFromBranches(tests)

    compareTests: (testA, testB) ->
      JSON.stringify(
        {id: testA.id, r: testA.revision, b: testA.branch}
      ) == JSON.stringify(
        {id: testB.id, r: testB.revision, b: testB.branch }
      )

    asyncTest: (testId, branch, rev) ->
      _that = this
      switch
        when testId? and branch? and rev?
          utilSvc.handleAsync dataSvc.asyncFindOne "tests", { "id" : testId, "revision" : rev, "branch" : branch }
        when testId? and branch?
          utilSvc.handleAsync dataSvc.asyncFind "tests", { "id" : testId, "branch" : branch }
            .then _that.getCurrentTest
        when testId?
          utilSvc.handleAsync dataSvc.asyncFind "tests", { "id" : testId }
            .then _that.getCurrentTest
        else
          deferred = do $q.defer
          deferred.reject( { msg: "At least a testId is required when getting a test" })
          deferred.promise

    asyncMaxRevision: (test, branch) ->
      deferred = do $q.defer
      console.log 'asyncMaxRevision',test,branch
      dataSvc.asyncFind "tests", { id: test.id, branch: branch }
        .then (tests) ->
          deferred.resolve if tests? and tests.length then _.max( tests, "revision" ).revision else 0

      deferred.promise

    asyncChangeBranch: (id, oldBranch, newBranch) ->
      query = { id: id, branch: oldBranch }
      update = { $set: { branch: newBranch } }

      dataSvc.asyncUpdate "tests", query, update

    asyncBranchesForTest: (testId) ->
      deferred = do $q.defer

      dataSvc.asyncFind "tests", { id: testId }
        .then (tests) ->
          deferred.resolve _.uniq _.pluck( tests, "branch" )

      deferred.promise

    asyncTestsForRevAndBranch: (revId, branch) ->
      utilSvc.handleAsync dataSvc.asyncFind "tests", { "rev_id" : revId, "branch" : branch }

    asyncSaveTest: (test) ->

      utilSvc.handleAsync dataSvc.asyncComplexSave "tests",
        [ "id", "revision", "branch" ],
        [ test.id, test.revision, test.branch ],
        [ "string", "int", "string" ], test

    asyncSaveAndRevisionTest: (test, newBranch) ->

      deferred = do $q.defer

      # copy and sanitize the new test
      newTest = angular.copy test
      delete newTest._id
      newTest.is_current = true
      if newBranch? then newTest.branch = newBranch

      _that = this



      # demote the original test from current and get the max revision
      $q.all( [
        @asyncMaxRevision(test.id, newTest.branch),
        @asyncTest(test.id, test.branch, test.revision)
      ] ).then (results) ->
        maxRevision = results[0]
        newTest.revision = maxRevision + 1

        savePromiseArray = [ _that.asyncSaveTest newTest ]

        if results[1]?
          oldTest = results[1]
          delete oldTest.is_current
          savePromiseArray.push asyncSaveTest oldTest


        $q.all(
          savePromiseArray
        ).then (results) ->

          deferred.resolve results[0]

      deferred.promise

    asyncRmBranch: (revId,branch) ->
      _that = this
      promises = []
      @asyncTestsForRevAndBranch revId,branch
      .then (tests) ->
        _.forEach tests, (v) ->
          result =  _that.asyncRmTest(v.id)
          console.log('result',result)
        #$q.all(promises)
        #.then() -> console.log('all tests removed')

    asyncRmTest: (testId) ->
      utilSvc.handleAsync dataSvc.asyncRemove "tests", testId

  new TestSvc()
]