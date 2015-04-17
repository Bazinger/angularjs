vprAppServices.factory 'blockSvc', [ '$log', '$q', 'dataSvc', 'utilSvc',  ($log, $q, dataSvc, utilSvc) ->

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

    asyncRmBlockRevision: (blockRevision) ->
      utilSvc.handleAsync dataSvc.asyncRemove "block_revisions", blockRevision

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

  new BlockSvc()
]