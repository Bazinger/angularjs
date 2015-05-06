vprAppServices.factory 'blockSvc', [  '$q', '$log', 'dataSvc', 'testSvc','utilSvc',  ( $q, $log, dataSvc, testSvc,utilSvc) ->

  class BlockSvc

    asyncBlockRevisionWithParent: (revId) ->

      deferred = do $q.defer

      _this = this

      @asyncBlockRevision revId
      .then (rev) ->
        _this.asyncBlock rev.block_id
        .then (block) ->
          deferred.resolve [block, rev]

      deferred.promise

    asyncBlockCount: () ->
      deferred = do $q.defer

      @asyncBlockList().then (arr) ->
        deferred.resolve(arr.length)
      , (error) ->
        $log.error("problem getting block list count #{error}")
        deferred.reject -1

      deferred.promise

    asyncBlockList: () ->
      utilSvc.handleAsync dataSvc.asyncFind "blocks", {}

    asyncBlock: (id) ->
      utilSvc.handleAsync dataSvc.asyncFindOne "blocks", { id: id }

    asyncSaveBlock: (block) ->
      utilSvc.handleAsync dataSvc.asyncSave "blocks", block

    asyncRmBlock: (id) ->
      utilSvc.handleAsync dataSvc.asyncRemove "blocks", id

    asyncRmBlock: (id) ->
      deferred = $q.defer()
      @asyncRemoveRevisionsForBlock id
      .then () ->
        utilSvc.handleAsync dataSvc.asyncRemove "blocks", id
        .then () ->
          deferred.resolve()

      deferred.promise

    asyncRevisionsForBlock: (block_id) ->
      utilSvc.handleAsync dataSvc.asyncFind "block_revisions", { block_id: block_id }

    asyncBlockRevision: (id) ->
      utilSvc.handleAsync dataSvc.asyncFindOne "block_revisions", { id: id }

    asyncSaveBlockRevision: (blockRevision) ->
      utilSvc.handleAsync dataSvc.asyncSave "block_revisions", blockRevision

    asyncRmBlockRevision: (id) ->
      deferred = $q.defer()
      # get tests linked to block revision and delete them
      testSvc.asyncTestsForRev id
      .then (tests) ->
        if tests.length
          promises = []
          for test in tests
            promises.push testSvc.asyncRmTest test.id
          $q.all promises
          .then () ->
            deferred.resolve()
        else
          deferred.resolve()

      deferred.promise
      .then () ->
        utilSvc.handleAsync dataSvc.asyncRemove "block_revisions", id

    asyncRemoveRevisionsForBlock: (id) ->
      deferred = $q.defer()
      that = this
      @asyncRevisionsForBlock id
      .then (revisions) ->
        if revisions.length
          promises = []
          for revision in revisions
            promises.push that.asyncRmBlockRevision revision.id
          $q.all promises
          .then () ->
            deferred.resolve()
        else
          deferred.resolve()

      deferred.promise

    asyncDefaultParamsForBlockRevision: (revId) ->
      default_params = []

      deferred = $q.defer()
      testSvc.asyncTestsForRev id
      .then (tests) ->
        device_params = []
        for test in tests
          if test.is_current
            device_params = device_params.concat getDeviceParamsFromTest test
            console.log 'device_params',device_params
        deferred.resolve device_params

      deferred.promise

#    parseDeviceParams: (test) ->
#      results = []
#      for test in tests
#        for param in
#        param.value.replace /#{(.*?)}/g, (s,match) ->
#          if typeof results[match] is 'undefined' then results.push
#          results[match].push param.value
#          #console.log (results)
#          #results.push { name: param.name, value: match, default: true}
#          #results.push {placeholder: match}
#          #console.log 'param.value: ',param.value,'s: ',s,'match: ',match
#        console.log 'results',results[match]
#      return results

    getAllDefaultParameters: (revs) ->
      console.log 'food'
      results = []
      for rev in revs
        testSvc.asyncTestsForRev rev
        .then (tests) ->
          console.log 'tests',tests
          for test in tests
            for param in test.test_params
              param.value.replace /#{(.*?)}/g, (str,match,start, usage) ->
                item=_.find results, (v) -> v.placeholder == match
                if typeof item is "undefined"
                  obj = {placeholder: match, usage: []}
                  obj.usage.push usage
                  results.push obj





    asyncCreateBlockRevisionItem:  (rev_id) ->
      deferred = $q.defer()

      @asyncBlockRevisionWithParent rev_id
      .then (results) ->

        item = {
          id: rev_id,
          name: results[0].name+' '+results[1].major_revision+'.'+results[1].minor_revision
          major_revision: results[1].major_revision
          minor_revision: results[1].minor_revision
        }
        deferred.resolve item

      deferred.promise

    asyncDeviceParamsForBlockRevision: (id) ->

      deferred = $q.defer()
      testSvc.asyncTestsForRev id
      .then (tests) ->
        device_params = []
        for test in tests
          if test.is_current
            device_params = device_params.concat getDeviceParamsFromTest test
        deferred.resolve device_params

      deferred.promise

  new BlockSvc()
]