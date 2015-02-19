vprAppServices.factory 'testSvc', [ '$log', '$q', 'dataSvc', 'utilSvc',  ($log, $q, dataSvc, utilSvc) ->

  class TestSvc

    asyncTestsForRev: (revId) ->
      utilSvc.handleAsync dataSvc.asyncFind "tests", { "rev_id" : revId }

    asyncTest: (testId) ->
      utilSvc.handleAsync dataSvc.asyncFindOne "tests", { "id" : testId }

    asyncSaveTest: (test) ->
      utilSvc.handleAsync dataSvc.asyncSave "tests", test

  new TestSvc()
]