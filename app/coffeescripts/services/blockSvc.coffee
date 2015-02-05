vprAppServices.factory 'blockSvc', [ '$log', '$q', 'dataSvc', 'utilSvc',  ($log, $q, dataSvc, utilSvc) ->

  class BlockSvc

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

  new BlockSvc()
]